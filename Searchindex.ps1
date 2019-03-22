Add-Type -AssemblyName System.Windows.Forms

function PopulateGrid()
{
	$form.Text = "Searching index - Please wait..."
	$searchme=$searchTerm.Text
	$sql="SELECT System.FileName, System.ItemPathDisplay, System.DateCreated, System.DateModified, system.itemurl, system.itemtypetext FROM japan.SYSTEMINDEX WHERE Contains(System.FileName, '"+$searchme+"') OR Contains('"+$searchme+"')"
	$adapter = new-object system.data.oledb.oleDBDataadapter -argumentlist $sql, "Provider=Search.CollatorDSO;Extended Properties=’Application=Windows’;"
	$ds = new-object system.data.dataset
	$adapter.Fill($ds)
	$form.Text = $ds.Tables[0].Rows.Count.ToString() + " record(s) found"
	$dataGridView.DataSource = $ds.Tables[0]
	$dataGridView.Columns | Foreach-Object{
		$_.AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCells
		$HeaderTextValue = $_.HeaderText
		$VisibleValue=1
		switch ($_.HeaderText)
		{
			"System.FileName" { $HeaderTextValue = "File/Attachment Name" }
			"System.ItemPathDisplay" { $HeaderTextValue = "Location" }
			"System.DateCreated" { $HeaderTextValue = "Date Created" }
			"System.DateModified" { $HeaderTextValue = "Date Modified" }
			"system.itemurl" 
			{ 
				$HeaderTextValue = "Index URL" 
				$VisibleValue=0
			}
			"system.itemtypetext" { $HeaderTextValue = "Type" }
		}
		$_.HeaderText = $HeaderTextValue
		$_.Visible=$VisibleValue
	$dataGridView.ReadOnly=1
	}
}

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(1024,768)

$searchTerm = New-Object System.Windows.Forms.TextBox 
$searchTerm.Location = New-Object System.Drawing.Size(95,15) 
$searchTerm.Size = New-Object System.Drawing.Size(($form.ClientSize.Width - 105),20) 
$searchTerm.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($searchTerm) 

$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Size=New-Object System.Drawing.Size($form.ClientSize.Width,($form.ClientSize.Height - 50))
$dataGridView.location=New-Object System.Drawing.Size(0,50)
$dataGridView.SelectionMode = 'FullRowSelect'
$dataGridView.MultiSelect = $false
$form.Controls.Add($dataGridView)
$dataGridView.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right

$go = New-Object System.Windows.Forms.Button
$go.Location = New-Object System.Drawing.Size(10,10)
$go.Size = New-Object System.Drawing.Size(75,25)
$go.text = "Search"
$form.Controls.Add($go)

$killme = New-Object System.Windows.Forms.Button
$killme.Location = New-Object System.Drawing.Size(300,475)
$killme.Size = New-Object System.Drawing.Size(75,25)
$killme.text = "exit"
$form.Controls.Add($killme)

$searchTerm.Add_KeyUp(
	{
		if($_.KeyCode -eq 'Enter')
		{
			PopulateGrid
		}
	}
)

$go.Add_Click(
	{
		PopulateGrid
	}
)

$dataGridView.Add_DoubleClick(
	{
		write-host $dataGridView.Rows.Count
		if ($dataGridView.Rows.Count -gt 1) {
			$dataGridView.SelectedRows| ForEach-Object{
				$exeparams = $dataGridView.Rows[$_.Index].Cells[4].Value
				$exeparams | Out-File 'file.txt' -encoding Unicode
				if ($exeparams.split(":")[0] -eq "mapi15")
    {
        $exeparams3="mapi://" + $exeparams.substring(9)
    }
				$exeparams2 = $exeparams -replace "^mapi15", "mapi"
				$exeparams3 | Out-File 'file.txt' -encoding Unicode -append
				$exeparams2 | Out-File 'file.txt' -encoding Unicode -append
				& start $exeparams3
			}
		}
	}
)

$killme.Add_Click(
	{
		$form.Close()
	}
)

$form.ShowDialog() 
