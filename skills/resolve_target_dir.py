# /// script
# dependencies = [
#     "python-dotenv",
#     "yt-dlp",
# ]
# ///
"""
在下載前決定影片的歸檔資料夾 docs/<分類>/<YYYYMMDD>/。

規則：
  1. 依頻道與標題判斷分類（與 /organize 相同規則）。
  2. 以上傳日期 (upload_date) 為起點：
     - 資料夾不存在或為空 → 使用該資料夾。
     - 已有 summary.md：內容含同一影片 ID 則使用，否則日期加 1 天後重新判斷。
     - 無 summary.md：含同一影片 ID 的檔案則使用；含其他影片的 .mp3 / .info.json / .txt 則加 1 天。

用法：
  uv run skills/resolve_target_dir.py "<YouTube URL>" [--create]
  uv run skills/resolve_target_dir.py --info-json <info.json 路徑> [--create]

輸出最後一行為：TARGET_DIR=<資料夾路徑>
"""
import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timedelta

from dotenv import load_dotenv

DOCS_ROOT = "docs"
MEDIA_SUFFIXES = (".mp3", ".info.json", ".txt")


def categorize(channel: str, title: str) -> str | None:
    if channel == "美投侃新闻":
        return os.path.join("美投君", "美投侃新聞")
    if channel == "美投讲美股":
        return os.path.join("美投君", "美投講美股")
    if "小翠時政財經" in channel or "小翠時政財經" in title or "小翠时政财经" in channel:
        if "會員直播" in title or "会员直播" in title:
            return os.path.join("小翠時政財經", "會員直播")
        if "每日要聞" in title or "每日要闻" in title:
            return os.path.join("小翠時政財經", "每日要聞")
        return os.path.join("小翠時政財經", "會員直播")
    if "美投" in channel or "美投" in title:
        return os.path.join("美投君", "美投侃新聞")
    return None


def fetch_remote_metadata(url: str) -> dict:
    load_dotenv()
    browser = os.environ.get("COOKIES_BROWSER", "")
    if browser.lower() in ("none", "false", ""):
        browser = None
    cookies_file = os.environ.get("COOKIES_PATH", "./cookies.txt")
    if cookies_file and cookies_file.lower() in ("none", "false", ""):
        cookies_file = None

    cmd = [
        sys.executable, "-m", "yt_dlp",
        "--skip-download", "--dump-single-json", "--no-playlist",
        "--js-runtimes", "node",
        "--remote-components", "ejs:github",
        "--extractor-args", "youtube:player_client=web_embedded,android,ios",
    ]
    if cookies_file and os.path.exists(cookies_file):
        cmd.extend(["--cookies", cookies_file])
    elif browser:
        cmd.extend(["--cookies-from-browser", browser])
    cmd.append(url)

    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        stderr_lower = (e.stderr or "").lower()
        if any(k in stderr_lower for k in ["sign in", "bot", "cookie", "member", "private"]):
            print(f"[COOKIE_ERROR] YouTube 拒絕存取。Cookie 可能無效、過期或未提供。\n詳細錯誤: {e.stderr}", file=sys.stderr)
        else:
            print(f"取得中繼資料失敗: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    return json.loads(result.stdout)


def folder_state(folder: str, video_id: str) -> str:
    """回傳 'free'（可使用）或 'occupied'（需加一天）。"""
    if not os.path.isdir(folder):
        return "free"
    names = os.listdir(folder)
    if "summary.md" in names:
        with open(os.path.join(folder, "summary.md"), "r", encoding="utf-8") as f:
            return "free" if video_id in f.read() else "occupied"
    if any(n.startswith(f"{video_id}.") for n in names):
        return "free"
    if any(n.endswith(MEDIA_SUFFIXES) for n in names):
        return "occupied"
    return "free"


def resolve(category: str, upload_date: str, video_id: str) -> tuple[str, int]:
    date = datetime.strptime(upload_date, "%Y%m%d")
    for shift in range(31):
        candidate = (date + timedelta(days=shift)).strftime("%Y%m%d")
        folder = os.path.join(DOCS_ROOT, category, candidate)
        if folder_state(folder, video_id) == "free":
            return folder, shift
    print("錯誤：連續 31 天的資料夾皆已被佔用，請手動確認。", file=sys.stderr)
    sys.exit(1)


def main():
    for stream in (sys.stdout, sys.stderr):
        if stream.encoding and stream.encoding.lower() != "utf-8":
            try:
                stream.reconfigure(encoding="utf-8")
            except AttributeError:
                pass

    parser = argparse.ArgumentParser(description="下載前決定影片歸檔資料夾（同日已有 summary.md 時順延一天）")
    parser.add_argument("url", nargs="?", help="YouTube 影片 URL")
    parser.add_argument("--info-json", help="改用本機 .info.json 取得中繼資料")
    parser.add_argument("--create", action="store_true", help="建立決定後的資料夾")
    args = parser.parse_args()

    if args.info_json:
        with open(args.info_json, "r", encoding="utf-8") as f:
            data = json.load(f)
    elif args.url:
        data = fetch_remote_metadata(args.url)
    else:
        parser.error("請指定 URL 或 --info-json")

    video_id = data.get("id", "")
    title = data.get("title", "")
    channel = data.get("channel") or data.get("uploader", "")
    upload_date = data.get("upload_date", "")

    category = categorize(channel, title)
    if category is None:
        print(f"[UNKNOWN_CATEGORY] 無法自動分類：頻道={channel} 標題={title}", file=sys.stderr)
        sys.exit(3)
    if not upload_date:
        print("錯誤：中繼資料缺少 upload_date。", file=sys.stderr)
        sys.exit(1)

    folder, shift = resolve(category, upload_date, video_id)
    if args.create:
        os.makedirs(folder, exist_ok=True)

    print(f"影片 ID  ：{video_id}")
    print(f"標題     ：{title}")
    print(f"頻道     ：{channel}")
    print(f"上傳日期 ：{upload_date}")
    print(f"分類     ：{category}")
    if shift:
        print(f"日期順延 ：+{shift} 天（原日期資料夾已有 summary.md 或其他影片）")
    print(f"TARGET_DIR={folder}")


if __name__ == "__main__":
    main()
