#Connect to Resource Manager COM Object
$resman = new-object -com "UIResource.UIResourceMgr"
$cacheInfo = $resman.GetCacheInfo()

#Enum Cache elements, compare date, and delete older than 5 days
$cacheinfo.GetCacheElements()  |
where-object {$_.LastReferenceTime -lt (get-date).AddDays(-5)} |
foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}