# Set working dir to scriptroot
$WorkingDir = "D:\Documents\POSH\PowerShell%20Scripts\CSharpConverter"
Push-Location $WorkingDir

# Import required packages
try{

	Add-Type -Path ".\packages\System.Collections.Immutable.1.1.37\lib\portable-net45+win8+wp8+wpa81\System.Collections.Immutable.dll"
	Add-Type -Path ".\packages\System.Reflection.Metadata.1.2.0\lib\portable-net45+win8\System.Reflection.Metadata.dll"
	Add-Type -Path ".\packages\Microsoft.Composition.1.0.27\lib\portable-net45+win8+wp8+wpa81\System.Composition.AttributedModel.dll"
	Add-Type -Path ".\packages\Microsoft.Composition.1.0.27\lib\portable-net45+win8+wp8+wpa81\System.Composition.TypedParts.dll"
	Add-Type -Path ".\packages\Microsoft.CodeAnalysis.Common.1.3.2\lib\net45\Microsoft.CodeAnalysis.dll"
	Add-Type -Path ".\packages\Microsoft.CodeAnalysis.CSharp.1.3.2\lib\net45\Microsoft.CodeAnalysis.CSharp.dll"
	Add-Type -Path ".\packages\Microsoft.CodeAnalysis.Workspaces.Common.1.3.2\lib\net45\Microsoft.CodeAnalysis.Workspaces.dll"
	Add-Type -Path ".\packages\Microsoft.CodeAnalysis.CSharp.Workspaces.1.3.2\lib\net45\Microsoft.CodeAnalysis.CSharp.Workspaces.dll"
    #Add-Type -Path ".\packages\Microsoft.CodeAnalysis.Workspaces.Common.1.3.2\lib\net45\Microsoft.CodeAnalysis.Workspaces.Desktop.dll"
    
} catch {

    throw $PSItem

}

# Rewriter class
class IfStatementVisitor : Microsoft.CodeAnalysis.CSharp.CSharpSyntaxWalker
{
	[System.Collections.Generic.List[Microsoft.CodeAnalysis.CSharp.Syntax.IfStatementSyntax]] $IfStatement

	IfStatementVisitor () {
		$this.IfStatement = New-Object System.Collections.Generic.List[Microsoft.CodeAnalysis.CSharp.Syntax.IfStatementSyntax]
	}

	[void] VisitIfStatement([Microsoft.CodeAnalysis.CSharp.Syntax.IfStatementSyntax] $node)
	{
		[Microsoft.CodeAnalysis.CSharp.Syntax.IfStatementSyntax](([Microsoft.CodeAnalysis.CSharp.CSharpSyntaxWalker]$this).VisitIfStatement($node))		
		$this.IfStatement.Add($node)		
	}
}



# Initialize empty list of SyntaxTree
$TreeList = New-Object "Collections.Generic.List[Microsoft.CodeAnalysis.SyntaxTree]"

# Get test CS content
$SourceText = Get-Content "D:\Downloads\SomeSource.cs" -Raw

# Parse source content and add to syntax tree
$TreeList.Add([Microsoft.CodeAnalysis.CSharp.CSharpSyntaxTree]::ParseText($SourceText))

# Get root node from compilation unit
$Root = $TreeList.GetCompilationUnitRoot()

# Spin up collector from visitor class and collect ifStatements
$Collector = [IfStatementVisitor]::new()
$Collector.Visit($Root)

$Collector


ForEach ($Statement in $Collector.IfStatement) {

	# Pull out condition
	$Condition = $Statement.Condition

	# Pull out type info
	$Type = $Condition.GetType().ToString()

	# Map and return PSObject
	[PSCustomObject]@{

		Type = $Type
		Identifier = $Condition.Identifier
		Expression = $Condition.Expression
		OperatorToken = $Condition.OperatorToken
		Operand = $Condition.Operand
		Name = $Condition.Name
		Left = $Condition.Left
		Operator = $Condition.Operator
		Right = $Condition.Right
		Statement = $Statement.Statement
		SpanStart = $Condition.SpanStart

	}

}
