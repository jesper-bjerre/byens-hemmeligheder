import Foundation

/// Danmarks postnumre med by og landsdel.
///
/// Genereret fra Dataforsyningens officielle registre — `/postnumre` joinet med
/// `/kommuner` over kommunens landsdel — den 31. juli 2026. Rediger ikke i
/// hånden; kør genereringen igen, hvis Danmark får et nyt postnummer.
///
/// ## Hvorfor tabellen ligger i koden
///
/// Quizmasteren vælger landsdel og derefter postnummer, og byen kommer af sig
/// selv. Blev listen hentet fra nettet, kunne appen ikke oprette en opgave i
/// felten uden dækning — og det er præcis dér, den bruges.
///
/// ## Hvorfor det er én tekstblok og ikke 1089 linjer Swift
///
/// En array-literal med tusind elementer koster typechecker-tid ved hver eneste
/// oversættelse. Blokken deles op én gang, første gang nogen slår op.
///
/// ## De 53 postnumre, der ligger i to landsdele
///
/// Et postnummer kan dække flere kommuner. Landsdelen er den, flest af dem
/// hører til. Det er et valg og ikke en sandhed — men et postnummer skal stå ét
/// sted på listen, ellers kan quizmasteren ikke finde sin opgave igen.
///
/// `nonisolated`, fordi tabellen er ren data. Uden det arver den projektets
/// `MainActor`-standard, og hierarkiet — som regnes uden for hovedtråden —
/// kan ikke slå et postnummer op.
nonisolated enum Postnumre {

    /// `postnummer|by|landsdel`, én pr. linje, sorteret efter postnummer.
    private static let raw = """
1050|København K|byenKoebenhavn
1051|København K|byenKoebenhavn
1052|København K|byenKoebenhavn
1053|København K|byenKoebenhavn
1054|København K|byenKoebenhavn
1055|København K|byenKoebenhavn
1056|København K|byenKoebenhavn
1057|København K|byenKoebenhavn
1058|København K|byenKoebenhavn
1059|København K|byenKoebenhavn
1060|København K|byenKoebenhavn
1061|København K|byenKoebenhavn
1062|København K|byenKoebenhavn
1063|København K|byenKoebenhavn
1064|København K|byenKoebenhavn
1065|København K|byenKoebenhavn
1066|København K|byenKoebenhavn
1067|København K|byenKoebenhavn
1068|København K|byenKoebenhavn
1069|København K|byenKoebenhavn
1070|København K|byenKoebenhavn
1071|København K|byenKoebenhavn
1072|København K|byenKoebenhavn
1073|København K|byenKoebenhavn
1074|København K|byenKoebenhavn
1100|København K|byenKoebenhavn
1101|København K|byenKoebenhavn
1102|København K|byenKoebenhavn
1103|København K|byenKoebenhavn
1104|København K|byenKoebenhavn
1105|København K|byenKoebenhavn
1106|København K|byenKoebenhavn
1107|København K|byenKoebenhavn
1110|København K|byenKoebenhavn
1111|København K|byenKoebenhavn
1112|København K|byenKoebenhavn
1113|København K|byenKoebenhavn
1114|København K|byenKoebenhavn
1115|København K|byenKoebenhavn
1116|København K|byenKoebenhavn
1117|København K|byenKoebenhavn
1118|København K|byenKoebenhavn
1119|København K|byenKoebenhavn
1120|København K|byenKoebenhavn
1121|København K|byenKoebenhavn
1122|København K|byenKoebenhavn
1123|København K|byenKoebenhavn
1124|København K|byenKoebenhavn
1125|København K|byenKoebenhavn
1126|København K|byenKoebenhavn
1127|København K|byenKoebenhavn
1128|København K|byenKoebenhavn
1129|København K|byenKoebenhavn
1130|København K|byenKoebenhavn
1131|København K|byenKoebenhavn
1150|København K|byenKoebenhavn
1151|København K|byenKoebenhavn
1152|København K|byenKoebenhavn
1153|København K|byenKoebenhavn
1154|København K|byenKoebenhavn
1155|København K|byenKoebenhavn
1156|København K|byenKoebenhavn
1157|København K|byenKoebenhavn
1158|København K|byenKoebenhavn
1159|København K|byenKoebenhavn
1160|København K|byenKoebenhavn
1161|København K|byenKoebenhavn
1162|København K|byenKoebenhavn
1164|København K|byenKoebenhavn
1165|København K|byenKoebenhavn
1166|København K|byenKoebenhavn
1167|København K|byenKoebenhavn
1168|København K|byenKoebenhavn
1169|København K|byenKoebenhavn
1170|København K|byenKoebenhavn
1171|København K|byenKoebenhavn
1172|København K|byenKoebenhavn
1173|København K|byenKoebenhavn
1174|København K|byenKoebenhavn
1175|København K|byenKoebenhavn
1200|København K|byenKoebenhavn
1201|København K|byenKoebenhavn
1202|København K|byenKoebenhavn
1203|København K|byenKoebenhavn
1204|København K|byenKoebenhavn
1205|København K|byenKoebenhavn
1206|København K|byenKoebenhavn
1207|København K|byenKoebenhavn
1208|København K|byenKoebenhavn
1209|København K|byenKoebenhavn
1210|København K|byenKoebenhavn
1211|København K|byenKoebenhavn
1212|København K|byenKoebenhavn
1213|København K|byenKoebenhavn
1214|København K|byenKoebenhavn
1215|København K|byenKoebenhavn
1216|København K|byenKoebenhavn
1218|København K|byenKoebenhavn
1219|København K|byenKoebenhavn
1220|København K|byenKoebenhavn
1221|København K|byenKoebenhavn
1250|København K|byenKoebenhavn
1251|København K|byenKoebenhavn
1252|København K|byenKoebenhavn
1253|København K|byenKoebenhavn
1254|København K|byenKoebenhavn
1255|København K|byenKoebenhavn
1256|København K|byenKoebenhavn
1257|København K|byenKoebenhavn
1259|København K|byenKoebenhavn
1260|København K|byenKoebenhavn
1261|København K|byenKoebenhavn
1263|København K|byenKoebenhavn
1264|København K|byenKoebenhavn
1265|København K|byenKoebenhavn
1266|København K|byenKoebenhavn
1267|København K|byenKoebenhavn
1268|København K|byenKoebenhavn
1270|København K|byenKoebenhavn
1271|København K|byenKoebenhavn
1300|København K|byenKoebenhavn
1301|København K|byenKoebenhavn
1302|København K|byenKoebenhavn
1303|København K|byenKoebenhavn
1304|København K|byenKoebenhavn
1306|København K|byenKoebenhavn
1307|København K|byenKoebenhavn
1308|København K|byenKoebenhavn
1309|København K|byenKoebenhavn
1310|København K|byenKoebenhavn
1311|København K|byenKoebenhavn
1312|København K|byenKoebenhavn
1313|København K|byenKoebenhavn
1314|København K|byenKoebenhavn
1315|København K|byenKoebenhavn
1316|København K|byenKoebenhavn
1317|København K|byenKoebenhavn
1318|København K|byenKoebenhavn
1319|København K|byenKoebenhavn
1320|København K|byenKoebenhavn
1321|København K|byenKoebenhavn
1322|København K|byenKoebenhavn
1323|København K|byenKoebenhavn
1324|København K|byenKoebenhavn
1325|København K|byenKoebenhavn
1326|København K|byenKoebenhavn
1327|København K|byenKoebenhavn
1328|København K|byenKoebenhavn
1329|København K|byenKoebenhavn
1350|København K|byenKoebenhavn
1352|København K|byenKoebenhavn
1353|København K|byenKoebenhavn
1354|København K|byenKoebenhavn
1355|København K|byenKoebenhavn
1356|København K|byenKoebenhavn
1357|København K|byenKoebenhavn
1358|København K|byenKoebenhavn
1359|København K|byenKoebenhavn
1360|København K|byenKoebenhavn
1361|København K|byenKoebenhavn
1362|København K|byenKoebenhavn
1363|København K|byenKoebenhavn
1364|København K|byenKoebenhavn
1365|København K|byenKoebenhavn
1366|København K|byenKoebenhavn
1367|København K|byenKoebenhavn
1368|København K|byenKoebenhavn
1369|København K|byenKoebenhavn
1370|København K|byenKoebenhavn
1371|København K|byenKoebenhavn
1400|København K|byenKoebenhavn
1401|København K|byenKoebenhavn
1402|København K|byenKoebenhavn
1403|København K|byenKoebenhavn
1406|København K|byenKoebenhavn
1407|København K|byenKoebenhavn
1408|København K|byenKoebenhavn
1409|København K|byenKoebenhavn
1410|København K|byenKoebenhavn
1411|København K|byenKoebenhavn
1412|København K|byenKoebenhavn
1413|København K|byenKoebenhavn
1414|København K|byenKoebenhavn
1415|København K|byenKoebenhavn
1416|København K|byenKoebenhavn
1417|København K|byenKoebenhavn
1418|København K|byenKoebenhavn
1419|København K|byenKoebenhavn
1420|København K|byenKoebenhavn
1421|København K|byenKoebenhavn
1422|København K|byenKoebenhavn
1423|København K|byenKoebenhavn
1424|København K|byenKoebenhavn
1425|København K|byenKoebenhavn
1426|København K|byenKoebenhavn
1427|København K|byenKoebenhavn
1428|København K|byenKoebenhavn
1429|København K|byenKoebenhavn
1430|København K|byenKoebenhavn
1432|København K|byenKoebenhavn
1433|København K|byenKoebenhavn
1434|København K|byenKoebenhavn
1435|København K|byenKoebenhavn
1436|København K|byenKoebenhavn
1437|København K|byenKoebenhavn
1438|København K|byenKoebenhavn
1439|København K|byenKoebenhavn
1440|København K|byenKoebenhavn
1441|København K|byenKoebenhavn
1450|København K|byenKoebenhavn
1451|København K|byenKoebenhavn
1452|København K|byenKoebenhavn
1453|København K|byenKoebenhavn
1454|København K|byenKoebenhavn
1455|København K|byenKoebenhavn
1456|København K|byenKoebenhavn
1457|København K|byenKoebenhavn
1458|København K|byenKoebenhavn
1459|København K|byenKoebenhavn
1460|København K|byenKoebenhavn
1461|København K|byenKoebenhavn
1462|København K|byenKoebenhavn
1463|København K|byenKoebenhavn
1464|København K|byenKoebenhavn
1465|København K|byenKoebenhavn
1466|København K|byenKoebenhavn
1467|København K|byenKoebenhavn
1468|København K|byenKoebenhavn
1470|København K|byenKoebenhavn
1471|København K|byenKoebenhavn
1472|København K|byenKoebenhavn
1473|København K|byenKoebenhavn
1550|København V|byenKoebenhavn
1551|København V|byenKoebenhavn
1552|København V|byenKoebenhavn
1553|København V|byenKoebenhavn
1554|København V|byenKoebenhavn
1555|København V|byenKoebenhavn
1556|København V|byenKoebenhavn
1557|København V|byenKoebenhavn
1558|København V|byenKoebenhavn
1559|København V|byenKoebenhavn
1560|København V|byenKoebenhavn
1561|København V|byenKoebenhavn
1562|København V|byenKoebenhavn
1563|København V|byenKoebenhavn
1564|København V|byenKoebenhavn
1567|København V|byenKoebenhavn
1568|København V|byenKoebenhavn
1569|København V|byenKoebenhavn
1570|København V|byenKoebenhavn
1571|København V|byenKoebenhavn
1572|København V|byenKoebenhavn
1573|København V|byenKoebenhavn
1574|København V|byenKoebenhavn
1575|København V|byenKoebenhavn
1576|København V|byenKoebenhavn
1577|København V|byenKoebenhavn
1600|København V|byenKoebenhavn
1601|København V|byenKoebenhavn
1602|København V|byenKoebenhavn
1603|København V|byenKoebenhavn
1604|København V|byenKoebenhavn
1605|København V|byenKoebenhavn
1606|København V|byenKoebenhavn
1607|København V|byenKoebenhavn
1608|København V|byenKoebenhavn
1609|København V|byenKoebenhavn
1610|København V|byenKoebenhavn
1611|København V|byenKoebenhavn
1612|København V|byenKoebenhavn
1613|København V|byenKoebenhavn
1614|København V|byenKoebenhavn
1615|København V|byenKoebenhavn
1616|København V|byenKoebenhavn
1617|København V|byenKoebenhavn
1618|København V|byenKoebenhavn
1619|København V|byenKoebenhavn
1620|København V|byenKoebenhavn
1621|København V|byenKoebenhavn
1622|København V|byenKoebenhavn
1623|København V|byenKoebenhavn
1624|København V|byenKoebenhavn
1631|København V|byenKoebenhavn
1632|København V|byenKoebenhavn
1633|København V|byenKoebenhavn
1634|København V|byenKoebenhavn
1635|København V|byenKoebenhavn
1650|København V|byenKoebenhavn
1651|København V|byenKoebenhavn
1652|København V|byenKoebenhavn
1653|København V|byenKoebenhavn
1654|København V|byenKoebenhavn
1655|København V|byenKoebenhavn
1656|København V|byenKoebenhavn
1657|København V|byenKoebenhavn
1658|København V|byenKoebenhavn
1659|København V|byenKoebenhavn
1660|København V|byenKoebenhavn
1661|København V|byenKoebenhavn
1662|København V|byenKoebenhavn
1663|København V|byenKoebenhavn
1664|København V|byenKoebenhavn
1665|København V|byenKoebenhavn
1666|København V|byenKoebenhavn
1667|København V|byenKoebenhavn
1668|København V|byenKoebenhavn
1669|København V|byenKoebenhavn
1670|København V|byenKoebenhavn
1671|København V|byenKoebenhavn
1672|København V|byenKoebenhavn
1673|København V|byenKoebenhavn
1674|København V|byenKoebenhavn
1675|København V|byenKoebenhavn
1676|København V|byenKoebenhavn
1677|København V|byenKoebenhavn
1699|København V|byenKoebenhavn
1700|København V|byenKoebenhavn
1701|København V|byenKoebenhavn
1702|København V|byenKoebenhavn
1703|København V|byenKoebenhavn
1704|København V|byenKoebenhavn
1705|København V|byenKoebenhavn
1706|København V|byenKoebenhavn
1707|København V|byenKoebenhavn
1708|København V|byenKoebenhavn
1709|København V|byenKoebenhavn
1710|København V|byenKoebenhavn
1711|København V|byenKoebenhavn
1712|København V|byenKoebenhavn
1714|København V|byenKoebenhavn
1715|København V|byenKoebenhavn
1716|København V|byenKoebenhavn
1717|København V|byenKoebenhavn
1718|København V|byenKoebenhavn
1719|København V|byenKoebenhavn
1720|København V|byenKoebenhavn
1721|København V|byenKoebenhavn
1722|København V|byenKoebenhavn
1723|København V|byenKoebenhavn
1724|København V|byenKoebenhavn
1725|København V|byenKoebenhavn
1726|København V|byenKoebenhavn
1727|København V|byenKoebenhavn
1728|København V|byenKoebenhavn
1729|København V|byenKoebenhavn
1730|København V|byenKoebenhavn
1731|København V|byenKoebenhavn
1732|København V|byenKoebenhavn
1733|København V|byenKoebenhavn
1734|København V|byenKoebenhavn
1735|København V|byenKoebenhavn
1736|København V|byenKoebenhavn
1737|København V|byenKoebenhavn
1738|København V|byenKoebenhavn
1739|København V|byenKoebenhavn
1749|København V|byenKoebenhavn
1750|København V|byenKoebenhavn
1751|København V|byenKoebenhavn
1752|København V|byenKoebenhavn
1753|København V|byenKoebenhavn
1754|København V|byenKoebenhavn
1755|København V|byenKoebenhavn
1756|København V|byenKoebenhavn
1757|København V|byenKoebenhavn
1758|København V|byenKoebenhavn
1759|København V|byenKoebenhavn
1760|København V|byenKoebenhavn
1761|København V|byenKoebenhavn
1762|København V|byenKoebenhavn
1763|København V|byenKoebenhavn
1764|København V|byenKoebenhavn
1765|København V|byenKoebenhavn
1766|København V|byenKoebenhavn
1770|København V|byenKoebenhavn
1771|København V|byenKoebenhavn
1772|København V|byenKoebenhavn
1773|København V|byenKoebenhavn
1774|København V|byenKoebenhavn
1775|København V|byenKoebenhavn
1777|København V|byenKoebenhavn
1799|København V|byenKoebenhavn
1800|Frederiksberg C|byenKoebenhavn
1801|Frederiksberg C|byenKoebenhavn
1802|Frederiksberg C|byenKoebenhavn
1803|Frederiksberg C|byenKoebenhavn
1804|Frederiksberg C|byenKoebenhavn
1805|Frederiksberg C|byenKoebenhavn
1806|Frederiksberg C|byenKoebenhavn
1807|Frederiksberg C|byenKoebenhavn
1808|Frederiksberg C|byenKoebenhavn
1809|Frederiksberg C|byenKoebenhavn
1810|Frederiksberg C|byenKoebenhavn
1811|Frederiksberg C|byenKoebenhavn
1812|Frederiksberg C|byenKoebenhavn
1813|Frederiksberg C|byenKoebenhavn
1814|Frederiksberg C|byenKoebenhavn
1815|Frederiksberg C|byenKoebenhavn
1816|Frederiksberg C|byenKoebenhavn
1817|Frederiksberg C|byenKoebenhavn
1818|Frederiksberg C|byenKoebenhavn
1819|Frederiksberg C|byenKoebenhavn
1820|Frederiksberg C|byenKoebenhavn
1822|Frederiksberg C|byenKoebenhavn
1823|Frederiksberg C|byenKoebenhavn
1824|Frederiksberg C|byenKoebenhavn
1825|Frederiksberg C|byenKoebenhavn
1826|Frederiksberg C|byenKoebenhavn
1827|Frederiksberg C|byenKoebenhavn
1828|Frederiksberg C|byenKoebenhavn
1829|Frederiksberg C|byenKoebenhavn
1850|Frederiksberg C|byenKoebenhavn
1851|Frederiksberg C|byenKoebenhavn
1852|Frederiksberg C|byenKoebenhavn
1853|Frederiksberg C|byenKoebenhavn
1854|Frederiksberg C|byenKoebenhavn
1855|Frederiksberg C|byenKoebenhavn
1856|Frederiksberg C|byenKoebenhavn
1857|Frederiksberg C|byenKoebenhavn
1860|Frederiksberg C|byenKoebenhavn
1861|Frederiksberg C|byenKoebenhavn
1862|Frederiksberg C|byenKoebenhavn
1863|Frederiksberg C|byenKoebenhavn
1864|Frederiksberg C|byenKoebenhavn
1865|Frederiksberg C|byenKoebenhavn
1866|Frederiksberg C|byenKoebenhavn
1867|Frederiksberg C|byenKoebenhavn
1868|Frederiksberg C|byenKoebenhavn
1870|Frederiksberg C|byenKoebenhavn
1871|Frederiksberg C|byenKoebenhavn
1872|Frederiksberg C|byenKoebenhavn
1873|Frederiksberg C|byenKoebenhavn
1874|Frederiksberg C|byenKoebenhavn
1875|Frederiksberg C|byenKoebenhavn
1876|Frederiksberg C|byenKoebenhavn
1877|Frederiksberg C|byenKoebenhavn
1878|Frederiksberg C|byenKoebenhavn
1879|Frederiksberg C|byenKoebenhavn
1900|Frederiksberg C|byenKoebenhavn
1901|Frederiksberg C|byenKoebenhavn
1902|Frederiksberg C|byenKoebenhavn
1903|Frederiksberg C|byenKoebenhavn
1904|Frederiksberg C|byenKoebenhavn
1905|Frederiksberg C|byenKoebenhavn
1906|Frederiksberg C|byenKoebenhavn
1908|Frederiksberg C|byenKoebenhavn
1909|Frederiksberg C|byenKoebenhavn
1910|Frederiksberg C|byenKoebenhavn
1911|Frederiksberg C|byenKoebenhavn
1912|Frederiksberg C|byenKoebenhavn
1913|Frederiksberg C|byenKoebenhavn
1914|Frederiksberg C|byenKoebenhavn
1915|Frederiksberg C|byenKoebenhavn
1916|Frederiksberg C|byenKoebenhavn
1917|Frederiksberg C|byenKoebenhavn
1920|Frederiksberg C|byenKoebenhavn
1921|Frederiksberg C|byenKoebenhavn
1922|Frederiksberg C|byenKoebenhavn
1923|Frederiksberg C|byenKoebenhavn
1924|Frederiksberg C|byenKoebenhavn
1925|Frederiksberg C|byenKoebenhavn
1926|Frederiksberg C|byenKoebenhavn
1927|Frederiksberg C|byenKoebenhavn
1928|Frederiksberg C|byenKoebenhavn
1950|Frederiksberg C|byenKoebenhavn
1951|Frederiksberg C|byenKoebenhavn
1952|Frederiksberg C|byenKoebenhavn
1953|Frederiksberg C|byenKoebenhavn
1954|Frederiksberg C|byenKoebenhavn
1955|Frederiksberg C|byenKoebenhavn
1956|Frederiksberg C|byenKoebenhavn
1957|Frederiksberg C|byenKoebenhavn
1958|Frederiksberg C|byenKoebenhavn
1959|Frederiksberg C|byenKoebenhavn
1960|Frederiksberg C|byenKoebenhavn
1961|Frederiksberg C|byenKoebenhavn
1962|Frederiksberg C|byenKoebenhavn
1963|Frederiksberg C|byenKoebenhavn
1964|Frederiksberg C|byenKoebenhavn
1965|Frederiksberg C|byenKoebenhavn
1966|Frederiksberg C|byenKoebenhavn
1967|Frederiksberg C|byenKoebenhavn
1970|Frederiksberg C|byenKoebenhavn
1971|Frederiksberg C|byenKoebenhavn
1972|Frederiksberg C|byenKoebenhavn
1973|Frederiksberg C|byenKoebenhavn
1974|Frederiksberg C|byenKoebenhavn
2000|Frederiksberg|byenKoebenhavn
2100|København Ø|byenKoebenhavn
2150|Nordhavn|byenKoebenhavn
2200|København N|byenKoebenhavn
2300|København S|byenKoebenhavn
2400|København NV|byenKoebenhavn
2450|København SV|byenKoebenhavn
2500|Valby|byenKoebenhavn
2600|Glostrup|koebenhavnsOmegn
2605|Brøndby|koebenhavnsOmegn
2610|Rødovre|koebenhavnsOmegn
2620|Albertslund|koebenhavnsOmegn
2625|Vallensbæk|koebenhavnsOmegn
2630|Taastrup|koebenhavnsOmegn
2635|Ishøj|koebenhavnsOmegn
2640|Hedehusene|koebenhavnsOmegn
2650|Hvidovre|koebenhavnsOmegn
2660|Brøndby Strand|koebenhavnsOmegn
2665|Vallensbæk Strand|koebenhavnsOmegn
2670|Greve|oestsjaelland
2680|Solrød Strand|oestsjaelland
2690|Karlslunde|oestsjaelland
2700|Brønshøj|byenKoebenhavn
2720|Vanløse|byenKoebenhavn
2730|Herlev|koebenhavnsOmegn
2740|Skovlunde|koebenhavnsOmegn
2750|Ballerup|koebenhavnsOmegn
2760|Måløv|koebenhavnsOmegn
2765|Smørum|nordsjaelland
2770|Kastrup|byenKoebenhavn
2791|Dragør|byenKoebenhavn
2800|Kongens Lyngby|koebenhavnsOmegn
2820|Gentofte|koebenhavnsOmegn
2830|Virum|koebenhavnsOmegn
2840|Holte|koebenhavnsOmegn
2850|Nærum|nordsjaelland
2860|Søborg|byenKoebenhavn
2870|Dyssegård|koebenhavnsOmegn
2880|Bagsværd|koebenhavnsOmegn
2900|Hellerup|byenKoebenhavn
2920|Charlottenlund|koebenhavnsOmegn
2930|Klampenborg|koebenhavnsOmegn
2942|Skodsborg|nordsjaelland
2950|Vedbæk|nordsjaelland
2960|Rungsted Kyst|nordsjaelland
2970|Hørsholm|nordsjaelland
2980|Kokkedal|nordsjaelland
2990|Nivå|nordsjaelland
3000|Helsingør|nordsjaelland
3050|Humlebæk|nordsjaelland
3060|Espergærde|nordsjaelland
3070|Snekkersten|nordsjaelland
3080|Tikøb|nordsjaelland
3100|Hornbæk|nordsjaelland
3120|Dronningmølle|nordsjaelland
3140|Ålsgårde|nordsjaelland
3150|Hellebæk|nordsjaelland
3200|Helsinge|nordsjaelland
3210|Vejby|nordsjaelland
3220|Tisvildeleje|nordsjaelland
3230|Græsted|nordsjaelland
3250|Gilleleje|nordsjaelland
3300|Frederiksværk|nordsjaelland
3310|Ølsted|nordsjaelland
3320|Skævinge|nordsjaelland
3330|Gørløse|nordsjaelland
3360|Liseleje|nordsjaelland
3370|Melby|nordsjaelland
3390|Hundested|nordsjaelland
3400|Hillerød|nordsjaelland
3450|Allerød|nordsjaelland
3460|Birkerød|nordsjaelland
3480|Fredensborg|nordsjaelland
3490|Kvistgård|nordsjaelland
3500|Værløse|koebenhavnsOmegn
3520|Farum|nordsjaelland
3540|Lynge|nordsjaelland
3550|Slangerup|nordsjaelland
3600|Frederikssund|nordsjaelland
3630|Jægerspris|nordsjaelland
3650|Ølstykke|nordsjaelland
3660|Stenløse|nordsjaelland
3670|Veksø Sjælland|nordsjaelland
3700|Rønne|bornholm
3720|Aakirkeby|bornholm
3730|Nexø|bornholm
3740|Svaneke|bornholm
3751|Østermarie|bornholm
3760|Gudhjem|bornholm
3770|Allinge|bornholm
3782|Klemensker|bornholm
3790|Hasle|bornholm
4000|Roskilde|oestsjaelland
4030|Tune|oestsjaelland
4040|Jyllinge|oestsjaelland
4050|Skibby|nordsjaelland
4060|Kirke Såby|oestsjaelland
4070|Kirke Hyllinge|oestsjaelland
4100|Ringsted|vestOgSydsjaelland
4130|Viby Sjælland|oestsjaelland
4140|Borup|oestsjaelland
4160|Herlufmagle|vestOgSydsjaelland
4171|Glumsø|vestOgSydsjaelland
4173|Fjenneslev|vestOgSydsjaelland
4174|Jystrup Midtsj|oestsjaelland
4180|Sorø|vestOgSydsjaelland
4190|Munke Bjergby|vestOgSydsjaelland
4200|Slagelse|vestOgSydsjaelland
4220|Korsør|vestOgSydsjaelland
4230|Skælskør|vestOgSydsjaelland
4241|Vemmelev|vestOgSydsjaelland
4242|Boeslunde|vestOgSydsjaelland
4243|Rude|vestOgSydsjaelland
4244|Agersø|vestOgSydsjaelland
4245|Omø|vestOgSydsjaelland
4250|Fuglebjerg|vestOgSydsjaelland
4261|Dalmose|vestOgSydsjaelland
4262|Sandved|vestOgSydsjaelland
4270|Høng|vestOgSydsjaelland
4281|Gørlev|vestOgSydsjaelland
4291|Ruds Vedby|vestOgSydsjaelland
4293|Dianalund|vestOgSydsjaelland
4295|Stenlille|vestOgSydsjaelland
4296|Nyrup|vestOgSydsjaelland
4300|Holbæk|vestOgSydsjaelland
4305|Orø|vestOgSydsjaelland
4320|Lejre|oestsjaelland
4330|Hvalsø|vestOgSydsjaelland
4340|Tølløse|vestOgSydsjaelland
4350|Ugerløse|vestOgSydsjaelland
4360|Kirke Eskilstrup|vestOgSydsjaelland
4370|Store Merløse|vestOgSydsjaelland
4390|Vipperød|vestOgSydsjaelland
4400|Kalundborg|vestOgSydsjaelland
4420|Regstrup|vestOgSydsjaelland
4440|Mørkøv|vestOgSydsjaelland
4450|Jyderup|vestOgSydsjaelland
4460|Snertinge|vestOgSydsjaelland
4470|Svebølle|vestOgSydsjaelland
4480|Store Fuglede|vestOgSydsjaelland
4490|Jerslev Sjælland|vestOgSydsjaelland
4500|Nykøbing Sj|vestOgSydsjaelland
4520|Svinninge|vestOgSydsjaelland
4532|Gislinge|vestOgSydsjaelland
4534|Hørve|vestOgSydsjaelland
4540|Fårevejle|vestOgSydsjaelland
4550|Asnæs|vestOgSydsjaelland
4560|Vig|vestOgSydsjaelland
4571|Grevinge|vestOgSydsjaelland
4572|Nørre Asmindrup|vestOgSydsjaelland
4573|Højby|vestOgSydsjaelland
4581|Rørvig|vestOgSydsjaelland
4583|Sjællands Odde|vestOgSydsjaelland
4591|Føllenslev|vestOgSydsjaelland
4592|Sejerø|vestOgSydsjaelland
4593|Eskebjerg|vestOgSydsjaelland
4600|Køge|oestsjaelland
4621|Gadstrup|oestsjaelland
4622|Havdrup|oestsjaelland
4623|Lille Skensved|oestsjaelland
4632|Bjæverskov|oestsjaelland
4640|Faxe|vestOgSydsjaelland
4652|Hårlev|vestOgSydsjaelland
4653|Karise|vestOgSydsjaelland
4654|Faxe Ladeplads|vestOgSydsjaelland
4660|Store Heddinge|vestOgSydsjaelland
4671|Strøby|vestOgSydsjaelland
4672|Klippinge|vestOgSydsjaelland
4673|Rødvig Stevns|vestOgSydsjaelland
4681|Herfølge|oestsjaelland
4682|Tureby|vestOgSydsjaelland
4683|Rønnede|vestOgSydsjaelland
4684|Holmegaard|vestOgSydsjaelland
4690|Haslev|vestOgSydsjaelland
4700|Næstved|vestOgSydsjaelland
4720|Præstø|vestOgSydsjaelland
4733|Tappernøje|vestOgSydsjaelland
4735|Mern|vestOgSydsjaelland
4736|Karrebæksminde|vestOgSydsjaelland
4750|Lundby|vestOgSydsjaelland
4760|Vordingborg|vestOgSydsjaelland
4771|Kalvehave|vestOgSydsjaelland
4772|Langebæk|vestOgSydsjaelland
4773|Stensved|vestOgSydsjaelland
4780|Stege|vestOgSydsjaelland
4791|Borre|vestOgSydsjaelland
4792|Askeby|vestOgSydsjaelland
4793|Bogø By|vestOgSydsjaelland
4800|Nykøbing F|vestOgSydsjaelland
4840|Nørre Alslev|vestOgSydsjaelland
4850|Stubbekøbing|vestOgSydsjaelland
4862|Guldborg|vestOgSydsjaelland
4863|Eskilstrup|vestOgSydsjaelland
4871|Horbelev|vestOgSydsjaelland
4872|Idestrup|vestOgSydsjaelland
4873|Væggerløse|vestOgSydsjaelland
4874|Gedser|vestOgSydsjaelland
4880|Nysted|vestOgSydsjaelland
4891|Toreby L|vestOgSydsjaelland
4892|Kettinge|vestOgSydsjaelland
4894|Øster Ulslev|vestOgSydsjaelland
4895|Errindlev|vestOgSydsjaelland
4900|Nakskov|vestOgSydsjaelland
4912|Harpelunde|vestOgSydsjaelland
4913|Horslunde|vestOgSydsjaelland
4920|Søllested|vestOgSydsjaelland
4930|Maribo|vestOgSydsjaelland
4941|Bandholm|vestOgSydsjaelland
4942|Askø|vestOgSydsjaelland
4943|Torrig L|vestOgSydsjaelland
4944|Fejø|vestOgSydsjaelland
4945|Femø|vestOgSydsjaelland
4951|Nørreballe|vestOgSydsjaelland
4952|Stokkemarke|vestOgSydsjaelland
4953|Vesterborg|vestOgSydsjaelland
4960|Holeby|vestOgSydsjaelland
4970|Rødby|vestOgSydsjaelland
4983|Dannemare|vestOgSydsjaelland
4990|Sakskøbing|vestOgSydsjaelland
5000|Odense C|fyn
5200|Odense V|fyn
5210|Odense NV|fyn
5220|Odense SØ|fyn
5230|Odense M|fyn
5240|Odense NØ|fyn
5250|Odense SV|fyn
5260|Odense S|fyn
5270|Odense N|fyn
5290|Marslev|fyn
5300|Kerteminde|fyn
5320|Agedrup|fyn
5330|Munkebo|fyn
5350|Rynkeby|fyn
5370|Mesinge|fyn
5380|Dalby|fyn
5390|Martofte|fyn
5400|Bogense|fyn
5450|Otterup|fyn
5462|Morud|fyn
5463|Harndrup|fyn
5464|Brenderup Fyn|fyn
5466|Asperup|fyn
5471|Søndersø|fyn
5474|Veflinge|fyn
5485|Skamby|fyn
5491|Blommenslyst|fyn
5492|Vissenbjerg|fyn
5500|Middelfart|fyn
5540|Ullerslev|fyn
5550|Langeskov|fyn
5560|Aarup|fyn
5580|Nørre Aaby|fyn
5591|Gelsted|fyn
5592|Ejby|fyn
5600|Faaborg|fyn
5601|Lyø|fyn
5602|Avernakø|fyn
5603|Bjørnø|fyn
5610|Assens|fyn
5620|Glamsbjerg|fyn
5631|Ebberup|fyn
5642|Millinge|fyn
5672|Broby|fyn
5683|Haarby|fyn
5690|Tommerup|fyn
5700|Svendborg|fyn
5750|Ringe|fyn
5762|Vester Skerninge|fyn
5771|Stenstrup|fyn
5772|Kværndrup|fyn
5792|Årslev|fyn
5800|Nyborg|fyn
5853|Ørbæk|fyn
5854|Gislev|fyn
5856|Ryslinge|fyn
5863|Ferritslev Fyn|fyn
5871|Frørup|fyn
5874|Hesselager|fyn
5881|Skårup Fyn|fyn
5882|Vejstrup|fyn
5883|Oure|fyn
5884|Gudme|fyn
5892|Gudbjerg Sydfyn|fyn
5900|Rudkøbing|fyn
5932|Humble|fyn
5935|Bagenkop|fyn
5943|Strynø|fyn
5953|Tranekær|fyn
5960|Marstal|fyn
5965|Birkholm|fyn
5970|Ærøskøbing|fyn
5985|Søby Ærø|fyn
6000|Kolding|sydjylland
6040|Egtved|sydjylland
6051|Almind|sydjylland
6052|Viuf|sydjylland
6064|Jordrup|sydjylland
6070|Christiansfeld|sydjylland
6091|Bjert|sydjylland
6092|Sønder Stenderup|sydjylland
6093|Sjølund|sydjylland
6094|Hejls|sydjylland
6100|Haderslev|sydjylland
6200|Aabenraa|sydjylland
6210|Barsø|sydjylland
6230|Rødekro|sydjylland
6240|Løgumkloster|sydjylland
6261|Bredebro|sydjylland
6270|Tønder|sydjylland
6280|Højer|sydjylland
6300|Gråsten|sydjylland
6310|Broager|sydjylland
6320|Egernsund|sydjylland
6330|Padborg|sydjylland
6340|Kruså|sydjylland
6360|Tinglev|sydjylland
6372|Bylderup-Bov|sydjylland
6392|Bolderslev|sydjylland
6400|Sønderborg|sydjylland
6430|Nordborg|sydjylland
6440|Augustenborg|sydjylland
6470|Sydals|sydjylland
6500|Vojens|sydjylland
6510|Gram|sydjylland
6520|Toftlund|sydjylland
6534|Agerskov|sydjylland
6535|Branderup J|sydjylland
6541|Bevtoft|sydjylland
6560|Sommersted|sydjylland
6580|Vamdrup|sydjylland
6600|Vejen|sydjylland
6621|Gesten|sydjylland
6622|Bække|sydjylland
6623|Vorbasse|sydjylland
6630|Rødding|sydjylland
6640|Lunderskov|sydjylland
6650|Brørup|sydjylland
6660|Lintrup|sydjylland
6670|Holsted|sydjylland
6682|Hovborg|sydjylland
6683|Føvling|sydjylland
6690|Gørding|sydjylland
6700|Esbjerg|sydjylland
6705|Esbjerg Ø|sydjylland
6710|Esbjerg V|sydjylland
6715|Esbjerg N|sydjylland
6720|Fanø|sydjylland
6731|Tjæreborg|sydjylland
6740|Bramming|sydjylland
6752|Glejbjerg|sydjylland
6753|Agerbæk|sydjylland
6760|Ribe|sydjylland
6771|Gredstedbro|sydjylland
6780|Skærbæk|sydjylland
6792|Rømø|sydjylland
6800|Varde|sydjylland
6818|Årre|sydjylland
6823|Ansager|sydjylland
6830|Nørre Nebel|sydjylland
6840|Oksbøl|sydjylland
6851|Janderup Vestj|sydjylland
6852|Billum|sydjylland
6853|Vejers Strand|sydjylland
6854|Henne|sydjylland
6855|Outrup|sydjylland
6857|Blåvand|sydjylland
6862|Tistrup|sydjylland
6870|Ølgod|sydjylland
6880|Tarm|sydjylland
6893|Hemmet|vestjylland
6900|Skjern|vestjylland
6920|Videbæk|vestjylland
6933|Kibæk|vestjylland
6940|Lem St|vestjylland
6950|Ringkøbing|vestjylland
6960|Hvide Sande|vestjylland
6971|Spjald|vestjylland
6973|Ørnhøj|vestjylland
6980|Tim|vestjylland
6990|Ulfborg|vestjylland
7000|Fredericia|sydjylland
7080|Børkop|sydjylland
7100|Vejle|sydjylland
7120|Vejle Øst|sydjylland
7130|Juelsminde|oestjylland
7140|Stouby|oestjylland
7150|Barrit|oestjylland
7160|Tørring|sydjylland
7171|Uldum|oestjylland
7173|Vonge|sydjylland
7182|Bredsten|sydjylland
7183|Randbøl|sydjylland
7184|Vandel|sydjylland
7190|Billund|sydjylland
7200|Grindsted|sydjylland
7250|Hejnsvig|sydjylland
7260|Sønder Omme|sydjylland
7270|Stakroge|vestjylland
7280|Sønder Felding|vestjylland
7300|Jelling|sydjylland
7321|Gadbjerg|sydjylland
7323|Give|sydjylland
7330|Brande|vestjylland
7361|Ejstrupholm|sydjylland
7362|Hampen|oestjylland
7400|Herning|vestjylland
7430|Ikast|vestjylland
7441|Bording|oestjylland
7442|Engesvang|oestjylland
7451|Sunds|vestjylland
7470|Karup J|vestjylland
7480|Vildbjerg|vestjylland
7490|Aulum|vestjylland
7500|Holstebro|vestjylland
7540|Haderup|vestjylland
7550|Sørvad|vestjylland
7560|Hjerm|vestjylland
7570|Vemb|vestjylland
7600|Struer|vestjylland
7620|Lemvig|vestjylland
7650|Bøvlingbjerg|vestjylland
7660|Bækmarksbro|vestjylland
7673|Harboøre|vestjylland
7680|Thyborøn|vestjylland
7700|Thisted|nordjylland
7730|Hanstholm|nordjylland
7741|Frøstrup|nordjylland
7742|Vesløs|nordjylland
7752|Snedsted|nordjylland
7755|Bedsted Thy|nordjylland
7760|Hurup Thy|vestjylland
7770|Vestervig|nordjylland
7790|Thyholm|vestjylland
7800|Skive|vestjylland
7830|Vinderup|vestjylland
7840|Højslev|vestjylland
7850|Stoholm Jyll|vestjylland
7860|Spøttrup|vestjylland
7870|Roslev|vestjylland
7884|Fur|vestjylland
7900|Nykøbing M|nordjylland
7950|Erslev|nordjylland
7960|Karby|nordjylland
7970|Redsted M|nordjylland
7980|Vils|nordjylland
7990|Øster Assels|nordjylland
8000|Aarhus C|oestjylland
8200|Aarhus N|oestjylland
8210|Aarhus V|oestjylland
8220|Brabrand|oestjylland
8230|Åbyhøj|oestjylland
8240|Risskov|oestjylland
8250|Egå|oestjylland
8260|Viby J|oestjylland
8270|Højbjerg|oestjylland
8300|Odder|oestjylland
8305|Samsø|oestjylland
8310|Tranbjerg J|oestjylland
8320|Mårslet|oestjylland
8330|Beder|oestjylland
8340|Malling|oestjylland
8350|Hundslund|oestjylland
8355|Solbjerg|oestjylland
8361|Hasselager|oestjylland
8362|Hørning|oestjylland
8370|Hadsten|oestjylland
8380|Trige|oestjylland
8381|Tilst|oestjylland
8382|Hinnerup|oestjylland
8400|Ebeltoft|oestjylland
8410|Rønde|oestjylland
8420|Knebel|oestjylland
8444|Balle|oestjylland
8450|Hammel|oestjylland
8462|Harlev J|oestjylland
8464|Galten|oestjylland
8471|Sabro|oestjylland
8472|Sporup|oestjylland
8500|Grenaa|oestjylland
8520|Lystrup|oestjylland
8530|Hjortshøj|oestjylland
8541|Skødstrup|oestjylland
8543|Hornslet|oestjylland
8544|Mørke|oestjylland
8550|Ryomgård|oestjylland
8560|Kolind|oestjylland
8570|Trustrup|oestjylland
8581|Nimtofte|oestjylland
8585|Glesborg|oestjylland
8586|Ørum Djurs|oestjylland
8592|Anholt|oestjylland
8600|Silkeborg|oestjylland
8620|Kjellerup|oestjylland
8632|Lemming|oestjylland
8641|Sorring|oestjylland
8643|Ans By|oestjylland
8653|Them|oestjylland
8654|Bryrup|oestjylland
8660|Skanderborg|oestjylland
8670|Låsby|oestjylland
8680|Ry|oestjylland
8700|Horsens|oestjylland
8721|Daugård|sydjylland
8722|Hedensted|oestjylland
8723|Løsning|oestjylland
8732|Hovedgård|oestjylland
8740|Brædstrup|oestjylland
8751|Gedved|oestjylland
8752|Østbirk|oestjylland
8762|Flemming|oestjylland
8763|Rask Mølle|oestjylland
8765|Klovborg|oestjylland
8766|Nørre Snede|vestjylland
8781|Stenderup|oestjylland
8783|Hornsyld|oestjylland
8789|Endelave|oestjylland
8799|Tunø|oestjylland
8800|Viborg|oestjylland
8830|Tjele|vestjylland
8831|Løgstrup|vestjylland
8832|Skals|vestjylland
8840|Rødkærsbro|oestjylland
8850|Bjerringbro|oestjylland
8860|Ulstrup|oestjylland
8870|Langå|oestjylland
8881|Thorsø|oestjylland
8882|Fårvang|oestjylland
8883|Gjern|oestjylland
8900|Randers C|oestjylland
8920|Randers NV|oestjylland
8930|Randers NØ|oestjylland
8940|Randers SV|oestjylland
8950|Ørsted|oestjylland
8960|Randers SØ|oestjylland
8961|Allingåbro|oestjylland
8963|Auning|oestjylland
8970|Havndal|oestjylland
8981|Spentrup|oestjylland
8983|Gjerlev J|oestjylland
8990|Fårup|oestjylland
9000|Aalborg|nordjylland
9200|Aalborg SV|nordjylland
9210|Aalborg SØ|nordjylland
9220|Aalborg Øst|nordjylland
9230|Svenstrup J|nordjylland
9240|Nibe|nordjylland
9260|Gistrup|nordjylland
9270|Klarup|nordjylland
9280|Storvorde|nordjylland
9293|Kongerslev|nordjylland
9300|Sæby|nordjylland
9310|Vodskov|nordjylland
9320|Hjallerup|nordjylland
9330|Dronninglund|nordjylland
9340|Asaa|nordjylland
9352|Dybvad|nordjylland
9362|Gandrup|nordjylland
9370|Hals|nordjylland
9380|Vestbjerg|nordjylland
9381|Sulsted|nordjylland
9382|Tylstrup|nordjylland
9400|Nørresundby|nordjylland
9430|Vadum|nordjylland
9440|Aabybro|nordjylland
9460|Brovst|nordjylland
9480|Løkken|nordjylland
9490|Pandrup|nordjylland
9492|Blokhus|nordjylland
9493|Saltum|nordjylland
9500|Hobro|nordjylland
9510|Arden|nordjylland
9520|Skørping|nordjylland
9530|Støvring|nordjylland
9541|Suldrup|nordjylland
9550|Mariager|oestjylland
9560|Hadsund|nordjylland
9574|Bælum|nordjylland
9575|Terndrup|nordjylland
9600|Aars|nordjylland
9610|Nørager|nordjylland
9620|Aalestrup|nordjylland
9631|Gedsted|vestjylland
9632|Møldrup|vestjylland
9640|Farsø|nordjylland
9670|Løgstør|nordjylland
9681|Ranum|nordjylland
9690|Fjerritslev|nordjylland
9700|Brønderslev|nordjylland
9740|Jerslev J|nordjylland
9750|Østervrå|nordjylland
9760|Vrå|nordjylland
9800|Hjørring|nordjylland
9830|Tårs|nordjylland
9850|Hirtshals|nordjylland
9870|Sindal|nordjylland
9881|Bindslev|nordjylland
9900|Frederikshavn|nordjylland
9940|Læsø|nordjylland
9970|Strandby|nordjylland
9981|Jerup|nordjylland
9982|Ålbæk|nordjylland
9990|Skagen|nordjylland
"""

    struct Sted: Identifiable, Hashable, Sendable {
        let code: String
        let city: String
        let region: String

        var id: String { code }
        /// "7100 Vejle" — sådan som quizmasteren genkender stedet.
        var label: String { "\(code) \(city)" }
    }

    /// Alle postnumre, sorteret efter nummer. Bygges én gang.
    static let all: [Sted] = raw.split(separator: "\n").compactMap { line in
        let parts = line.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        return Sted(code: String(parts[0]), city: String(parts[1]), region: String(parts[2]))
    }

    private static let byCode: [String: Sted] =
        Dictionary(all.map { ($0.code, $0) }, uniquingKeysWith: { first, _ in first })

    /// `nil` for et postnummer, der ikke findes i Danmark.
    static func sted(_ code: String) -> Sted? { byCode[code] }

    static func city(_ code: String) -> String? { byCode[code]?.city }

    static func region(_ code: String) -> String? { byCode[code]?.region }

    /// Postnumrene i én landsdel, sorteret efter nummer.
    static func inRegion(_ region: String) -> [Sted] { all.filter { $0.region == region } }
}
