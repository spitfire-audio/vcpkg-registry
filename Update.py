from pathlib import Path
import sys
import json
from subprocess import Popen, PIPE, STDOUT

def run_cmd(cmd, exit_on_failure=True, hide_output=False):
    if exit_on_failure:
        if "|" in cmd:
            cmd = cmd + "; test ${PIPESTATUS[0]} -eq 0"
        else:
            cmd = cmd + " || exit 1"

    try:
        lines = []

        with Popen(cmd, stdout=PIPE, stderr=STDOUT, shell=True) as p:
            for line in p.stdout:
                line = line.decode('utf-8')

                if not hide_output:
                    print(line, end='')
                lines.append(line)

        if not p.returncode == 0 and exit_on_failure:
            print(cmd + " - Returned: " + str(p.returncode))
            exit(1)

        return [p.returncode, lines]
    except:
        print("Error executing cmd: " + cmd)

        if exit_on_failure:
            exit(1)

        return None

def get_script_dir():
    return Path(sys.path[0])

ports_dir = get_script_dir() / "ports"

ports = {}

for port in ports_dir.glob("*"):
    if port.is_dir() and not port.name == "sentry-native" and not port.name == "libarchive":
        vcpkg_file = Path(port / "vcpkg.json")
        if vcpkg_file.exists():
            vcpkg_json = json.loads(vcpkg_file.read_bytes())

            info = {
                "name": vcpkg_json["name"],
                "port-version": vcpkg_json["port-version"]
            }
            if "version-semver" in vcpkg_json:
                info["version"] = vcpkg_json["version-semver"]
                info["version-name"] = "version-semver"
            else:
                info["version"] = vcpkg_json["version"]
                info["version-name"] = "version"
            ports[info["name"]] = info


versions_dir = get_script_dir() / "versions"

for version_file in versions_dir.rglob("*"):
    if version_file.stem in ports:
        port_info = ports[version_file.stem]
        try:
            version_json = json.loads(version_file.read_bytes())
            for count, version_info in enumerate(version_json["versions"]):
                if version_info["port-version"] == port_info["port-version"]:
                    if port_info["version-name"] in version_info and version_info[port_info["version-name"]] == port_info["version"]:
                        break
            else:
                err, git_sha = run_cmd(f"git rev-parse HEAD:ports/{port_info['name']}/")

                version_json["versions"].insert(0, {
                    "git-tree": git_sha[0].strip(),
                    "version": port_info["version"],
                    "port-version": port_info["port-version"]
                })
                out = json.dumps(version_json, indent=4)
                version_file.write_text(out)
        except KeyError:
            print(f"ERROR {version_file}")


baseline_file = versions_dir / "baseline.json"
baseline_json = json.loads(baseline_file.read_bytes())

for port in ports:
    port_info = ports[port]
    baseline_json["default"][port] = {
        "baseline": port_info[port_info["version-name"]],
        "port-version": port_info["port-version"]
    }

out = json.dumps(baseline_json, indent=4)
baseline_file.write_text(out)

