module NatFlDlgWorkAround

using NativeFileDialog, Dates

"Returns OS version on Mac or v0 if other OS"
function macos_version()
    Sys.isapple() || return v"0"
    osversion = read(`sw_vers --productVersion`, String)
    return VersionNumber(osversion)
end
# export macos_version

const BUGGY_MACOS = macos_version() >= v"15"

function pick_file(path=""; filterlist="") 
    BUGGY_MACOS || return NativeFileDialog.pick_file(path; filterlist)
    return pick_file_workaround(path; filterlist)
end
export pick_file

function check_if_log_noise(s, starttime)
    s == "" && return nothing
    format = DateFormat("yyyy-mm-dd HH:MM:SS.sss")

    lognoise = length(s) >= 23 && (ss = s[1:23]; true) &&
        !isnothing(tryparse(DateTime, ss, format)) &&
        starttime <= DateTime(ss, format) <= now() && 
        occursin("osascript", s) &&
        occursin("IMKClient", s)

    lognoise || @warn "OS information, possibly irrelevant: $s"

    return nothing
end
export check_if_log_noise

function pick_file_workaround(path; filterlist)
    stderr_buffer = IOBuffer()
    if isempty(path) 
        script = """POSIX path of (choose file with prompt "Pick a file:")"""
    else
        script = 
""" set strPath to POSIX file "$path"
POSIX path of (choose file with prompt "Pick a file:" default location strPath)"""
    end
    cmd = `osascript -e $script`
    flpath = ""
    warn_noise = ""
    starttime = now()
    try
        flpath = readchomp(pipeline(cmd; stderr=stderr_buffer));
        warn_noise = take!(stderr_buffer) |> String;
    catch
        flpath = ""
        warn_noise = ""
    end
    check_if_log_noise(warn_noise, starttime)
    return flpath
end


end # module NatFlDlgWorkAround
