Function Get-JCSystemGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]

    param
    (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup',
            Position = 0,
            HelpMessage = 'The name of the JumpCloud System Group you want to return the members of.')]
        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            HelpMessage = 'If searching for a System Group using the GroupID populate the GroupID in the -ByID field.')]
        [Alias('_id', 'id')]
        [String]$ByID
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and results ArraryByID'
        $rawResults = @()
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')
        {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_SystemGroupName_ID
            Write-Debug 'Populating SystemIDHash'
            $SystemIDHash = Get-Hash_SystemID_HostName
        }

    }


    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')

        {
            foreach ($Group in $GroupName)

            {
                if ($GroupNameHash.containsKey($Group))

                {
                    $Group_ID = $GroupNameHash.Get_Item($Group)
                    Write-Debug "$Group_ID"

                    [int]$skip = 0 #Do not change!
                    Write-Debug "Setting skip to $skip"

                    while ($rawResults.Count -ge $skip)
                    {
                        $limitURL = "$JCUrlBasePath/api/v2/Systemgroups/$Group_ID/members?limit=$limit&skip=$skip"
                        Write-Debug $limitURL
                        $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                        $skip += $limit
                        $rawResults += $results
                    }

                    foreach ($uid in $rawResults)
                    {
                        $Systemname = $SystemIDHash.Get_Item($uid.to.id)

                        $FomattedResult = [pscustomobject]@{

                            'GroupName' = $GroupName
                            'System'    = $Systemname
                            'SystemID'  = $uid.to.id
                        }

                        $resultsArray += $FomattedResult
                    }

                    $rawResults = $null

                }

                else { Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud System groups."}

            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            [int]$skip = 0 #Do not change!

            while ($resultsArray.Count -ge $skip)
            {

                $limitURL = "$JCUrlBasePath/api/v2/Systemgroups/$ByID/members?limit=$limit&skip=$skip"
                Write-Debug $limitURL
                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $skip += $limit
                $resultsArray += $results
            }

        }
    }
    end
    {
        return $resultsArray
    }
}