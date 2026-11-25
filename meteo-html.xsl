<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8" indent="yes"/>

<xsl:template match="/">
<html lang="fr">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Mes températures</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 40px 20px;
            font-family: "Segoe UI", Arial, sans-serif;
            background: linear-gradient(135deg, #e0f2fe, #f8fafc);
            color: #1e293b;
        }

        h1 {
            text-align: center;
            font-size: 2.2em;
            color: #0c4a6e;
            margin: 0 0 35px 0;
        }

        h2 {
            max-width: 480px;
            margin: 35px auto 12px auto;
            font-size: 1.2em;
            color: #0369a1;
            border-left: 5px solid #0ea5e9;
            padding-left: 12px;
        }

        table {
            width: 100%;
            max-width: 480px;
            margin: 0 auto;
            border-collapse: collapse;
            background: #ffffff;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 14px rgba(15, 23, 42, 0.12);
        }

        th {
            background: #0369a1;
            color: #ffffff;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
        }

        td {
            padding: 10px 16px;
            border-bottom: 1px solid #e2e8f0;
        }

        tr:nth-child(even) td {
            background: #f1f5f9;
        }

        tr:hover td {
            background: #e0f2fe;
        }

        td.temp {
            font-weight: 700;
            text-align: left;
        }

        td.chaud { color: #c2410c; }
        td.doux  { color: #15803d; }
        td.frais { color: #0369a1; }

        .legende {
            max-width: 480px;
            margin: 40px auto 0 auto;
            text-align: center;
            font-size: 0.9em;
            color: #64748b;
        }

        .legende .chaud { color: #c2410c; font-weight: 700; }
        .legende .doux  { color: #15803d; font-weight: 700; }
        .legende .frais { color: #0369a1; font-weight: 700; }
    </style>
</head>
<body>
    <h1>Mesures météorologiques</h1>

    <xsl:for-each select="meteo/mesure">
        <h2>
            Date : <xsl:value-of select="@date"/>
        </h2>

        <table border="1">
            <tr>
                <th>Ville</th>
                <th>Température</th>
            </tr>

            <xsl:for-each select="ville">
                <tr>
                    <td><xsl:value-of select="@nom"/></td>
                    <td>
                        <xsl:attribute name="class">
                            <xsl:choose>
                                <xsl:when test="@temperature &gt;= 25">temp chaud</xsl:when>
                                <xsl:when test="@temperature &gt;= 20">temp doux</xsl:when>
                                <xsl:otherwise>temp frais</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="@temperature"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:for-each>

    <p class="legende">
        <span class="chaud">25° et plus : chaud</span> |
        <span class="doux">20° à 24° : doux</span> |
        <span class="frais">moins de 20° : frais</span>
    </p>
</body>
</html>
</xsl:template>
</xsl:stylesheet>