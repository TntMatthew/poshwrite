<#
.SYNOPSIS
poshwrite - a powershell text writer

.DESCRIPTION
This is a posh script I had written because I was bored. For some reason,
I decided I should continue making it. Don't ask why. I do not know myself.

Note that this only has the ability to write text, not edit. That's why I'm
not calling it a text editor, but a text writer. Consider it a posh version of
copy con, but with an actual interface and added features.

Want an actual CLI text editor? This is not what you're looking for. Move along.

For documentation on the actual usage of this thing, use the :? command inside of
the thing.
#>

$Text = [String]::Empty
$CurLineNumber = 1

function DrawEditor($TitleString)
{
    Clear-Host

    if ($TitleString -eq $null)
    {
        $TitleString = "poshwrite - type :? for help"
    }

    Write-Host ("{0,30} {1,0} {2,-30}" -f "", $TitleString, "") -ForegroundColor Black -BackgroundColor Gray

    $i = 1
    foreach ($line in $Text.Split("`n"))
    {
        if ($i -ne $CurLineNumber)
        {
            Write-Host "$($i)`t " -NoNewline -ForegroundColor White -BackgroundColor DarkGray
            Write-Host " " -NoNewline
            Write-Host $line
            $i++
        }
    }
}

function ExitEditor()
{
    $exitPromptResult = Read-Host -prompt "Save the file? (y/n/c)"
    if ($exitPromptResult -eq "y")
    {
        SaveFile($Text)
        exit
    }
    elseif ($exitPromptResult -eq "c")
    {
        DrawEditor("Quitting cancelled")
    }
    else
    {
        exit
    }
}

   
function SaveFile($textToWrite)
{
    $path = Read-Host "Enter path (leave blank to cancel)"
    if (-Not ([String]::IsNullOrEmpty($path)))
    {
        [System.IO.File]::WriteAllText($path, $textToWrite);
    }
}

DrawEditor

#[String]$prewrittenLine = [String]::Empty

try
{
    while ($true)
    {
        Write-Host "$($CurLineNumber)`t " -NoNewline -ForegroundColor White -BackgroundColor DarkGray
        Write-Host " " -NoNewline

        $i = Read-Host

        if ($i -eq ":?")
        {
            Write-Host " There's not really much help to go over, really.`n"`
            "The actual interface itself is extremely simple, and I assume you're not an idiot,`n"`
            "so the only things covered here will be the commands.`n"`
            "The commands are basically the only real thing this has over the good ol' copy con command`n"`
            "that doesn't work in PowerShell. To use commands, you just start typing them on a blank line.`n"`
            "They're prefixed by a colon so you shouldn't input them accidentally.`n"
            Write-Host ":? " -NoNewline -ForegroundColor Cyan
            Write-Host "Shows this list of commands, which is what you are reading right now."
            Write-Host ":about " -NoNewline -ForegroundColor Cyan
            Write-Host "Shows a little information about this thing."
            Write-Host ":clear " -NoNewline -ForegroundColor Cyan
            Write-Host "Clears everything that has been previously written."
            Write-Host ":quit " -NoNewline -ForegroundColor Cyan
            Write-Host "Quits the writer."
            Write-Host ":redo " -NoNewline -ForegroundColor Cyan
            Write-Host "Deletes the last line. Partially useful."
            Write-Host ":replace " -NoNewline -ForegroundColor Cyan
            Write-Host "Performs a simple find and replace operation on the current text.`n"

            Write-Host "Press any key to return to the editor..." -NoNewline
            [Console]::ReadKey($true)
            DrawEditor
        }
        elseif ($i -eq ":quit")
        {
            ExitEditor
        }
        elseif ($i -eq ":replace")
        {
            try
            {
                $findString = Read-Host -Prompt "Enter text to find"
                $replaceString = Read-Host -Prompt "Enter text to replace"
                $Text = $Text.Replace($findString, $replaceString)
                DrawEditor("Replaced $($findString) with $($replaceString)")
            }
            catch [System.Management.Automation.MethodInvocationException]
            {
                DrawEditor("Replace failed; you didn't enter anything")
            }
        }
        elseif ($i -eq ":about")
        {
            Write-Host "poshwrite - a powershell text writer" -ForegroundColor Cyan
            Write-Host " This is a posh script I wrote because I was bored. For some reason, I decided to continue making it.`n"`
                       "Don't ask. I do not know myself.`n"`
                       "Note that this only hass the ability to write text, not edit, so that's why I'm not calling it a text`n"`
                       "editor. Do you actually want to be able to edit text from the command line? Well, this is not that program.`n"`
                       "Look somewhere else.`n"

            Write-Host "Press any key to return to the editor..." -NoNewline
            [Console]::ReadKey($true)
            DrawEditor
        }
        elseif ($i -eq ":clear")
        {
            $promptRes = Read-Host -Prompt "Erase all text? (y/n)"
            if ($promptRes -eq "y")
            {
                $CurLineNumber = 1
                $Text = [String]::Empty
            }
            DrawEditor
        }
        elseif ($i -eq ":redo")
        {
            $splitText = New-Object System.Collections.ArrayList
            $splitText.AddRange($Text.Split("`n"))
            $splitText.RemoveAt($splitText.Count - 2)
            $Text = [String]::Join([Environment]::NewLine, $splitText.ToArray())
            $CurLineNumber--
            DrawEditor
        }
        else
        {
            $Text += $i + [Environment]::NewLine
            $CurLineNumber++
        }
    }
}
finally
{
    Write-Host "`n"
}