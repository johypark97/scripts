#!/usr/bin/env python3

from argparse import ArgumentParser, Namespace
from datetime import datetime
from json import loads
from pathlib import Path
from platform import machine, system
from shutil import which
from subprocess import CompletedProcess, run
from typing import Literal, TypedDict
from urllib.request import Request, urlopen


class GitHubApi:
    ENCODING = "utf-8"
    BASE_URL = "https://api.github.com/repos"
    HEADER = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    def __init__(self, owner: str, repository: str) -> None:
        self.__owner = owner
        self.__repository = repository

    @property
    def owner(self) -> str:
        return self.__owner

    @property
    def repository(self) -> str:
        return self.__repository

    def get_latest_release(self) -> "GitHubApi.Type.Release":
        json_data = self._send("releases/latest")
        return GitHubApi.Type.to_release(json_data)

    def _create_url(self, endpoint: str) -> str:
        return f"{self.BASE_URL}/{self.owner}/{self.repository}/{endpoint}"

    def _send(self, endpoint: str) -> dict:
        url = self._create_url(endpoint)
        with urlopen(Request(url, headers=self.HEADER)) as response:
            data: str = response.read().decode(self.ENCODING)
            return loads(data)

    class Type:
        @staticmethod
        def to_release(data: dict) -> "GitHubApi.Type.Release":
            return GitHubApi.Type.Release(
                {
                    "assets_url": data["assets_url"],
                    "assets": [GitHubApi.Type.to_asset(x) for x in data["assets"]],
                    "author": GitHubApi.Type.to_author(data["author"]),
                    "created_at": data["created_at"],
                    "draft": data["draft"],
                    "html_url": data["html_url"],
                    "id": data["id"],
                    "name": data.get("name"),
                    "node_id": data["node_id"],
                    "prerelease": data["prerelease"],
                    "published_at": data.get("published_at"),
                    "tag_name": data["tag_name"],
                    "tarball_url": data.get("tarball_url"),
                    "target_commitish": data["target_commitish"],
                    "upload_url": data["upload_url"],
                    "url": data["url"],
                    "zipball_url": data.get("zipball_url"),
                }
            )

        @staticmethod
        def to_asset(data: dict) -> "GitHubApi.Type.Asset":
            return GitHubApi.Type.Asset(
                {
                    "browser_download_url": data["browser_download_url"],
                    "content_type": data["content_type"],
                    "created_at": data["created_at"],
                    "digest": data.get("digest"),
                    "download_count": data["download_count"],
                    "id": data["id"],
                    "label": data.get("label"),
                    "name": data["name"],
                    "node_id": data["node_id"],
                    "size": data["size"],
                    "state": data["state"],
                    "updated_at": data["updated_at"],
                    "uploader": (
                        GitHubApi.Type.to_uploader(data["uploader"])
                        if data.get("uploader") is not None
                        else None
                    ),
                    "url": data["url"],
                }
            )

        @staticmethod
        def to_uploader(data: dict) -> "GitHubApi.Type.Uploader":
            return GitHubApi.Type.Uploader(
                {
                    "avatar_url": data["avatar_url"],
                    "events_url": data["events_url"],
                    "followers_url": data["followers_url"],
                    "following_url": data["following_url"],
                    "gists_url": data["gists_url"],
                    "gravatar_id": data.get("gravatar_id"),
                    "html_url": data["html_url"],
                    "id": data["id"],
                    "login": data["login"],
                    "node_id": data["node_id"],
                    "organizations_url": data["organizations_url"],
                    "received_events_url": data["received_events_url"],
                    "repos_url": data["repos_url"],
                    "site_admin": data["site_admin"],
                    "starred_url": data["starred_url"],
                    "subscriptions_url": data["subscriptions_url"],
                    "type": data["type"],
                    "url": data["url"],
                }
            )

        @staticmethod
        def to_author(data: dict) -> "GitHubApi.Type.Author":
            return GitHubApi.Type.Author(
                {
                    "avatar_url": data["avatar_url"],
                    "events_url": data["events_url"],
                    "followers_url": data["followers_url"],
                    "following_url": data["following_url"],
                    "gists_url": data["gists_url"],
                    "gravatar_id": data.get("gravatar_id"),
                    "html_url": data["html_url"],
                    "id": data["id"],
                    "login": data["login"],
                    "node_id": data["node_id"],
                    "organizations_url": data["organizations_url"],
                    "received_events_url": data["received_events_url"],
                    "repos_url": data["repos_url"],
                    "site_admin": data["site_admin"],
                    "starred_url": data["starred_url"],
                    "subscriptions_url": data["subscriptions_url"],
                    "type": data["type"],
                    "url": data["url"],
                }
            )

        class Release(TypedDict):
            assets_url: str
            assets: list["GitHubApi.Type.Asset"]
            author: "GitHubApi.Type.Author"
            created_at: str
            draft: bool
            html_url: str
            id: int
            name: str | None
            node_id: str
            prerelease: bool
            published_at: str | None
            tag_name: str
            tarball_url: str | None
            target_commitish: str
            upload_url: str
            url: str
            zipball_url: str | None

        class Asset(TypedDict):
            browser_download_url: str
            content_type: str
            created_at: str
            digest: str | None
            download_count: int
            id: int
            label: str | None
            name: str
            node_id: str
            size: int
            state: Literal["open", "uploaded"]
            updated_at: str
            uploader: "GitHubApi.Type.Uploader | None"
            url: str

        class _User(TypedDict):
            avatar_url: str
            events_url: str
            followers_url: str
            following_url: str
            gists_url: str
            gravatar_id: str | None
            html_url: str
            id: int
            login: str
            node_id: str
            organizations_url: str
            received_events_url: str
            repos_url: str
            site_admin: bool
            starred_url: str
            subscriptions_url: str
            type: str
            url: str

        class Uploader(_User):
            pass

        class Author(_User):
            pass


class NeovimInstaller:
    GITHUB_OWNER = "neovim"
    GITHUB_REPOSITORY = "neovim"

    ASSET_NAME_MAP = {
        ("Linux", "x86_64"): "nvim-linux-x86_64.appimage",
        ("Linux", "aarch64"): "nvim-linux-arm64.appimage",
    }

    BLOCK_SIZE = 512 * 1024  # 512 KB
    DATE_FORMAT = "%Y-%m-%d %H:%M:%S %z"
    PERMISSION = 0o755

    def __init__(self) -> None:
        self.__api = GitHubApi(self.GITHUB_OWNER, self.GITHUB_REPOSITORY)

        self.__system = system()
        self.__machine = machine()

    def print_latest_release_information(self) -> None:
        latest_release = self.__api.get_latest_release()

        date = latest_release["published_at"]
        formatted_date = (
            datetime.fromisoformat(date).astimezone().strftime(self.DATE_FORMAT)
            if date is not None
            else "N/A"
        )

        print("Latest Release:")
        print("- Version:", latest_release["tag_name"])
        print(f"- Date: {formatted_date} ({date})")

        print("Assets:")
        for asset in latest_release["assets"]:
            size = asset["size"] / 1024
            if size < 1024:
                size = f"{size:.2f} KB"
            else:
                size /= 1024
                size = f"{size:.2f} MB"

            print(f"- {asset['name']} ({size})")

    def install(self, path: Path) -> None:
        target_asset_name = self._get_target_asset_name()

        latest_release = self.__api.get_latest_release()
        target_asset = self._get_target_asset(latest_release, target_asset_name)

        self._download_asset(target_asset, path)
        path.chmod(self.PERMISSION)

        print(f"Neovim {latest_release['tag_name']} installed successfully:")
        print("-", path)

    def uninstall(self, path: Path) -> None:
        if not path.exists():
            raise FileNotFoundError(f"File '{path}' does not exist.")

        path.unlink()

        print(f"Neovim uninstalled successfully:")
        print("-", path)

    def _get_target_asset_name(self) -> str:
        target_asset_name = self.ASSET_NAME_MAP.get((self.__system, self.__machine))

        if target_asset_name is None:
            raise NeovimInstaller.UnsupportedPlatformError(
                f"Unsupported platform: {self.__system} {self.__machine}"
            )

        return target_asset_name

    def _get_target_asset(
        self, release: GitHubApi.Type.Release, target_asset_name: str
    ) -> GitHubApi.Type.Asset:
        for asset in release["assets"]:
            if asset["name"] == target_asset_name:
                return asset

        raise NeovimInstaller.AssetNotFoundError(
            f"Asset '{target_asset_name}' not found in the latest release."
        )

    def _download_asset(self, asset: GitHubApi.Type.Asset, path: Path) -> None:
        if path.exists():
            raise FileExistsError(f"File '{path}' already exists.")

        with urlopen(
            Request(asset["browser_download_url"], headers=GitHubApi.HEADER)
        ) as response:
            with path.open("wb") as file:
                downloaded_size = 0
                while True:
                    chunk: bytes = response.read(self.BLOCK_SIZE)
                    if not chunk:
                        break

                    file.write(chunk)

                    downloaded_size += len(chunk)
                    percent = downloaded_size / asset["size"] * 100
                    print(f"\rDownloading... {percent:.2f}%", end="", flush=True)
                print()

    class UnsupportedPlatformError(Exception):
        pass

    class AssetNotFoundError(Exception):
        pass


class UpdateAlternatives:
    COMMAND = "update-alternatives"

    def __init__(self) -> None:
        if which(self.COMMAND) is None:
            raise UpdateAlternatives.CommandError(
                f"Command '{self.COMMAND}' is not available."
            )

    def install(
        self, link: Path, name: str, path: Path, priority: int
    ) -> CompletedProcess:
        return self._run("--install", link, name, path, str(priority))

    def list(self, name: str) -> CompletedProcess:
        return self._run("--list", name)

    def query(self, name: str) -> CompletedProcess:
        return self._run("--query", name)

    def uninstall(self, name: str, path: Path) -> CompletedProcess:
        return self._run("--remove", name, path)

    def _run(self, *args) -> CompletedProcess:
        result: CompletedProcess = run(
            [self.COMMAND, *args], capture_output=True, text=True
        )

        if result.returncode != 0:
            raise UpdateAlternatives.CommandError(result.stderr.strip())

        return result

    class CommandError(Exception):
        pass


class Parser:
    DEST_COMMAND = "command"

    INSTALL_DEFAULT_FILENAME = "nvim.appimage"
    INSTALL_DEFAULT_PATH = "/usr/local/bin"

    ALTERNATIVES_DEFAULT_LINK = "/usr/bin/vi"
    ALTERNATIVES_DEFAULT_NAME = "vi"
    ALTERNATIVES_DEFAULT_PRIORITY = 50

    def __init__(self) -> None:
        self.__parser = ArgumentParser(description="Neovim Latest Release Installer")

        self.__parser.add_argument(
            "-f",
            "--filename",
            type=str,
            help=f"Executable filename. Default is '{self.INSTALL_DEFAULT_FILENAME}'.",
            default=self.INSTALL_DEFAULT_FILENAME,
        )

        self.__parser.add_argument(
            "-p",
            "--path",
            type=str,
            help=f"Installation path. Default is '{self.INSTALL_DEFAULT_PATH}'.",
            default=self.INSTALL_DEFAULT_PATH,
        )

        self.__add_subparsers()

    def parse_args(self) -> Namespace:
        return self.__parser.parse_args()

    def __add_subparsers(self) -> None:
        subparser = self.__parser.add_subparsers(dest=self.DEST_COMMAND, required=True)

        # -------- Fetch Command --------

        subparser.add_parser("fetch", help="Fetch the latest release information")

        # -------- Install Command --------

        subparser.add_parser("install", help="Install the latest Neovim release")

        # -------- Uninstall Command --------

        subparser.add_parser("uninstall", help="Uninstall Neovim")

        # -------- Alternatives Command --------

        alternatives_subparser = subparser.add_parser(
            "alternatives", help="Manage alternatives for Neovim"
        )

        group = alternatives_subparser.add_mutually_exclusive_group(required=True)
        group.add_argument(
            "-l",
            "--list",
            action="store_true",
            help="List Neovim in alternatives.",
        )
        group.add_argument(
            "-q",
            "--query",
            action="store_true",
            help="Query Neovim in alternatives.",
        )
        group.add_argument(
            "-i",
            "--install",
            action="store_true",
            help="Install Neovim to alternatives.",
        )
        group.add_argument(
            "-u",
            "--uninstall",
            action="store_true",
            help="Uninstall Neovim from alternatives.",
        )

        alternatives_subparser.add_argument(
            "-L",
            "--link",
            type=str,
            help=f"Link for update-alternatives. Default is '{self.ALTERNATIVES_DEFAULT_LINK}'.",
            default=self.ALTERNATIVES_DEFAULT_LINK,
        )
        alternatives_subparser.add_argument(
            "-N",
            "--name",
            type=str,
            help=f"Name for update-alternatives. Default is '{self.ALTERNATIVES_DEFAULT_NAME}'.",
            default=self.ALTERNATIVES_DEFAULT_NAME,
        )
        alternatives_subparser.add_argument(
            "-P",
            "--priority",
            type=int,
            help=f"Priority for update-alternatives. Default is {self.ALTERNATIVES_DEFAULT_PRIORITY}.",
            default=self.ALTERNATIVES_DEFAULT_PRIORITY,
        )


class Main:
    @staticmethod
    def main() -> None:
        args = Parser().parse_args()

        neovim_path = Path(args.path) / args.filename

        if args.command == "fetch":
            Main.fetch_latest_neovim_release()
        elif args.command == "install":
            Main.install_neovim(neovim_path)
        elif args.command == "uninstall":
            Main.uninstall_neovim(neovim_path)
        elif args.command == "alternatives":
            if args.list:
                Main.list_alternatives(args.name)
            elif args.query:
                Main.query_alternatives(args.name)
            elif args.install:
                Main.install_alternatives(
                    Path(args.link), args.name, neovim_path, args.priority
                )
            elif args.uninstall:
                Main.uninstall_alternatives(args.name, neovim_path)

    @staticmethod
    def fetch_latest_neovim_release() -> None:
        try:
            NeovimInstaller().print_latest_release_information()
        except Exception as e:
            print("Error:", e)

    @staticmethod
    def install_neovim(path: Path) -> None:
        try:
            NeovimInstaller().install(path)
        except Exception as e:
            print("Error:", e)

    @staticmethod
    def uninstall_neovim(path: Path) -> None:
        try:
            NeovimInstaller().uninstall(path)
        except Exception as e:
            print("Error:", e)

    @staticmethod
    def list_alternatives(name: str) -> None:
        try:
            result = UpdateAlternatives().list(name)
            print(result.stdout, end="")
        except Exception as e:
            print("Error:", e)

    @staticmethod
    def query_alternatives(name: str) -> None:
        try:
            result = UpdateAlternatives().query(name)
            print(result.stdout, end="")
        except Exception as e:
            print("Error:", e)

    @staticmethod
    def install_alternatives(link: Path, name: str, path: Path, priority: int) -> None:
        try:
            UpdateAlternatives().install(link, name, path, priority)
            print(f"Alternatives '{name}' installed successfully:")
            print(f"- {path} ({priority})")
        except Exception as e:
            print("Error:", e)

    @staticmethod
    def uninstall_alternatives(name: str, path: Path) -> None:
        try:
            UpdateAlternatives().uninstall(name, path)
            print(f"Alternatives '{name}' uninstalled successfully:")
            print("-", path)
        except Exception as e:
            print("Error:", e)


if __name__ == "__main__":
    Main.main()
