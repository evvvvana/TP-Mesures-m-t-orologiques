<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" media-type="image/svg+xml" encoding="UTF-8" indent="yes"/>

<xsl:template match="/">

<svg xmlns="http://www.w3.org/2000/svg"
     width="850" height="300"
     viewBox="0 0 850 300">

    <text x="300" y="25"
          font-size="20" font-weight="bold">
        Histogramme des températures
    </text>

    <!-- Axe horizontal -->
    <line x1="40" y1="220" x2="820" y2="220"
          stroke="black" stroke-width="2"/>

    <!-- Parcours des villes de la première date -->
    <xsl:for-each select="meteo/mesure[1]/ville">

        <xsl:variable name="n" select="@nom"/>
        <xsl:variable name="t2"
          select="/meteo/mesure[2]/ville[@nom=$n]/@temperature"/>

        <xsl:variable name="x" select="30 + (position() - 1) * 98"/>

        <!-- Première barre : date 1 -->
        <rect x="{$x}" y="{220 - number(@temperature)*5}"
              width="25"
              height="{number(@temperature)*5}"
              fill="#3498db">

            <animate attributeName="height"
                     from="0"
                     to="{number(@temperature)*5}"
                     dur="1.5s"
                     fill="freeze"/>

            <animate attributeName="y"
                     from="220"
                     to="{220 - number(@temperature)*5}"
                     dur="1.5s"
                     fill="freeze"/>
        </rect>

        <!-- Deuxième barre : date 2 -->
        <rect x="{$x + 28}" y="{220 - number($t2)*5}"
              width="25"
              height="{number($t2)*5}"
              fill="#e67e22">

            <animate attributeName="height"
                     from="0"
                     to="{number($t2)*5}"
                     dur="1.5s"
                     fill="freeze"/>

            <animate attributeName="y"
                     from="220"
                     to="{220 - number($t2)*5}"
                     dur="1.5s"
                     fill="freeze"/>
        </rect>

        <!-- Nom de la ville -->
        <text x="{$x - 5}" y="240" font-size="10">
            <xsl:value-of select="@nom"/>
        </text>

    </xsl:for-each>

    <!-- Légende -->
    <rect x="250" y="265" width="15" height="12"
          fill="#3498db"/>
    <text x="270" y="276" font-size="12">
        01-01-2006
    </text>

    <rect x="400" y="265" width="15" height="12"
          fill="#e67e22"/>
    <text x="420" y="276" font-size="12">
        02-01-2006
    </text>

</svg>

</xsl:template>
</xsl:stylesheet>
