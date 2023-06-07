$ds = new-object "System.Data.DataSet" "dsServers"
$ds.ReadXmlSchema('C:\ipfx\Test.xsd')

$ds.ReadXml("\\cent-2-001\QueueData\IPFXQueueData.xml")
$dtProd = $ds.Tables[2]
$cn = new-object System.Data.SqlClient.SqlConnection("Server=cent-5-049;User ID=ipfx;Password=Plymouth.2018");
$cn.Open()
$bc = new-object ("System.Data.SqlClient.SqlBulkCopy") $cn
$bc.DestinationTableName = "ipfx.dbo.QueueData"
$bc.WriteToServer($dtProd)
$cn.Close()
