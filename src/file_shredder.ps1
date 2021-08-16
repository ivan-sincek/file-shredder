Write-Host "#######################################################################";
Write-Host "#                                                                     #";
Write-Host "#                          File Shredder 1.2                          #";
Write-Host "#                                   by Ivan Sincek                    #";
Write-Host "#                                                                     #";
Write-Host "# GitHub repository at github.com/ivan-sincek/file-shredder.          #";
Write-Host "# Feel free to donate bitcoin at 1BrZM6T7G9RN8vbabnfXu4M6Lpgztq6Y14.  #";
Write-Host "#                                                                     #";
Write-Host "#######################################################################";
if ($args.Count -ne 1) {
	Write-Host "Usage: .\file_shredder.ps1 <file-to-shred>";
} else {
	$size = 2048;
	$buffer = $null;
	$rng = $null;
	$stream = $null;
	$file = $null;
	try {
		$file = Get-Item $args[0].Trim() -ErrorAction SilentlyContinue;
		if ($file -eq $null) {
			Write-Host "Path does not exists";
		} elseif ($file -isnot [IO.FileInfo]) {
			Write-Host "Path specified is not a file";
		} else {
			$file.Attributes = "Normal";
			$sectors = [Math]::Ceiling($file.Length / $size);
			$buffer = New-Object Byte[] $size;
			$rng = New-Object Security.Cryptography.RNGCryptoServiceProvider;
			$stream = New-Object IO.FileStream($file.FullName, [IO.FileAccess]::Write);
			# number of rewrites (seven)
			for ($i = 0; $i -lt 7; $i++) {
				$stream.Position = 0;
				for ($j = 0; $j -lt $sectors; $j++) {
					$rng.GetBytes($buffer);
					$stream.Write($buffer, 0, $buffer.Length);
				}
			}
			$stream.SetLength(0);
			$stream.Close();
			$file.CreationTime = "09/06/2069 04:20:00 AM";
			$file.LastWriteTime = "09/06/2069 04:20:00 AM";
			$file.LastAccessTime = "09/06/2069 04:20:00 AM";
			$file.Delete();
			Write-Host "File has been shredded successfully";
		}
	} catch {
		Write-Host $_.Exception.InnerException.Message;
	} finally {
		if ($buffer -ne $null) {
			$buffer.Clear();
		}
		if ($rng -ne $null) {
			$rng.Dispose();
		}
		if ($stream -ne $null) {
			$stream.Close();
			$stream.Dispose();
		}
		if ($file -ne $null) {
			Clear-Variable -Name "file";
		}
	}
}
