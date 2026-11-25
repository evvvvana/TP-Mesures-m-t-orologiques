# Module XML – Devoir 3 : Mesures météorologiques

> Validation de données XML (**DTD** et **XML Schema**) et présentation des résultats
> avec **XSLT** : tableaux **HTML** et histogramme **SVG** animé.

---

## Sommaire

1. [Présentation](#1-présentation)
2. [Contenu du projet](#2-contenu-du-projet)
3. [Structure des données](#3-structure-des-données)
4. [Validation](#4-validation)
5. [Transformations XSLT](#5-transformations-xslt)
6. [Exécution](#6-exécution)
7. [Résultats](#7-résultats)
8. [Conclusion](#8-conclusion)

---

## 1. Présentation

Ce projet traite des **mesures de température** relevées dans 8 villes du Maroc
(Casa, Rabat, Fes, Oujda, Tanger, Marrakech, Ouarzazat, Agadir) à deux dates
différentes : le 1er et le 2 janvier 2006.

Les mêmes données sont :

- **décrites et validées** de deux façons : une **DTD** et un **XML Schema (XSD)** ;
- **affichées** de deux façons grâce à **XSLT** : des **tableaux HTML** et un
  **histogramme SVG**.

## 2. Contenu du projet

| Fichier | Rôle |
|---|---|
| `meteo.dtd` | Définition de la structure avec une **DTD** |
| `meteo-dtd.xml` | Document XML validé par `meteo.dtd` (affiché en HTML par `meteo-html.xsl`) |
| `meteo.xsd` | Définition de la structure avec un **XML Schema (XSD)** |
| `meteo-xsd.xml` | Document XML validé par `meteo.xsd` (affiché en SVG par `meteo-svg.xsl`) |
| `meteo-html.xsl` | Feuille XSLT : transforme le XML en tableaux **HTML** (mis en forme avec du CSS) |
| `meteo-svg.xsl` | Feuille XSLT : transforme le XML en **histogramme SVG** animé |
| `captures/` | Captures d'écran des résultats |

## 3. Structure des données

```
meteo
 └── mesure (attribut : date)
      └── ville (attributs : nom, temperature)
```

- Le document contient au moins une `mesure`, et chaque `mesure` contient au moins une `ville`.
- La `ville` est un élément vide : ses informations sont dans ses attributs.

Extrait des données (`meteo-xsd.xml`) :

```xml
<meteo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:noNamespaceSchemaLocation="meteo.xsd">
    <mesure date="2006-01-01">
        <ville nom="Casa" temperature="22"/>
        <ville nom="Rabat" temperature="20"/>
        <ville nom="Fes" temperature="18"/>
        <!-- ... -->
    </mesure>
    <mesure date="2006-01-02">
        <!-- mêmes villes, autres températures -->
    </mesure>
</meteo>
```

## 4. Validation

### 4.1 DTD (`meteo.dtd`)

```dtd
<!ELEMENT meteo (mesure+)>

<!ELEMENT mesure (ville+)>
<!ATTLIST mesure date CDATA #REQUIRED>

<!ELEMENT ville EMPTY>
<!ATTLIST ville
    nom CDATA #REQUIRED
    temperature CDATA #REQUIRED
>
```

- `meteo` contient une ou plusieurs `mesure` (`mesure+`).
- `mesure` contient une ou plusieurs `ville` (`ville+`) et possède un attribut `date` obligatoire.
- `ville` est vide (`EMPTY`) et possède deux attributs obligatoires : `nom` et `temperature`.

Le document `meteo-dtd.xml` est relié à la DTD et à la feuille de style dans son en-tête :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="meteo-html.xsl"?>
<!DOCTYPE meteo SYSTEM "meteo.dtd">
```

### 4.2 XML Schema (`meteo.xsd`)

Même structure que la DTD, avec des **types de données** plus précis :

```xml
<xs:element name="ville" maxOccurs="unbounded">
    <xs:complexType>
        <xs:attribute name="nom"         type="xs:string"  use="required"/>
        <xs:attribute name="temperature" type="xs:integer" use="required"/>
    </xs:complexType>
</xs:element>

<!-- sur l'élément mesure -->
<xs:attribute name="date" type="xs:date" use="required"/>
```

| Attribut | Type | Signification |
|---|---|---|
| `nom` | `xs:string` | chaîne de caractères |
| `temperature` | `xs:integer` | nombre entier |
| `date` | `xs:date` | format `AAAA-MM-JJ` |

C'est pourquoi `meteo-xsd.xml` utilise des dates comme `2006-01-01`, alors que
`meteo-dtd.xml` (où la date est un simple texte, `CDATA`) utilise `2006-1-1`.

### 4.3 Résultat de la validation

- `meteo-dtd.xml` est valide par rapport à `meteo.dtd` (aucun message d'erreur).
- `meteo-xsd.xml` est valide par rapport à `meteo.xsd` (message `validates`).

Commandes utilisables pour reproduire la validation :

```bash
xmllint --noout --valid  meteo-dtd.xml
xmllint --noout --schema meteo.xsd meteo-xsd.xml
```

## 5. Transformations XSLT

### 5.1 Tableaux HTML (`meteo-html.xsl`)

Une boucle `xsl:for-each` parcourt chaque `mesure` (un tableau par date), puis une
seconde boucle parcourt les `ville` de cette mesure (une ligne par ville) :

```xml
<xsl:for-each select="meteo/mesure">
    <h2>Date : <xsl:value-of select="@date"/></h2>

    <table>
        <tr>
            <th>Ville</th>
            <th>Température</th>
        </tr>

        <xsl:for-each select="ville">
            <tr>
                <td><xsl:value-of select="@nom"/></td>
                <td><xsl:value-of select="@temperature"/></td>
            </tr>
        </xsl:for-each>
    </table>
</xsl:for-each>
```

### 5.2 Histogramme SVG (`meteo-svg.xsl`)

La feuille parcourt les villes de la **première** date. Pour chacune, elle retrouve la
température de la **deuxième** date grâce à un **prédicat XPath** :

```xml
<xsl:for-each select="meteo/mesure[1]/ville">

    <xsl:variable name="n"  select="@nom"/>
    <xsl:variable name="t2" select="/meteo/mesure[2]/ville[@nom=$n]/@temperature"/>
    <xsl:variable name="x"  select="40 + position() * 95"/>
    ...
</xsl:for-each>
```

- `meteo/mesure[1]/ville` : villes de la première mesure ;
- `ville[@nom=$n]` : la même ville dans la deuxième mesure ;
- `position() * 95` : décale chaque groupe de barres vers la droite.

Les **valeurs d'attributs** sont calculées avec la notation `{ ... }`. La hauteur d'une
barre est proportionnelle à la température (échelle : 5 pixels par degré), et l'ordonnée
`y` est calculée à partir de l'axe horizontal situé à `y = 220` :

```xml
<rect x="{$x}" y="{220 - number(@temperature)*5}"
      width="25"
      height="{number(@temperature)*5}"
      fill="#3498db">

    <animate attributeName="height" from="0"
             to="{number(@temperature)*5}" dur="1.5s" fill="freeze"/>
    <animate attributeName="y" from="220"
             to="{220 - number(@temperature)*5}" dur="1.5s" fill="freeze"/>
</rect>
```

Les deux éléments `<animate>` font « pousser » la barre depuis l'axe : la hauteur passe
de 0 à sa valeur finale pendant que `y` remonte en même temps. La deuxième barre
(couleur `#e67e22`, date 2) est construite de la même manière, décalée de 28 pixels
(`x="{$x + 28}"`).

## 6. Exécution

Chaque document XML est relié à sa feuille de style par l'instruction
`<?xml-stylesheet ... ?>`. Il suffit donc de l'ouvrir dans un navigateur :

| Fichier à ouvrir | Résultat affiché |
|---|---|
| `meteo-dtd.xml` | Tableaux **HTML** (feuille `meteo-html.xsl`) |
| `meteo-xsd.xml` | Histogramme **SVG** animé (feuille `meteo-svg.xsl`) |

> **Remarque importante :** les navigateurs modernes (Firefox, Chrome, Edge) bloquent le
> chargement d'une feuille XSLT lorsque le fichier est ouvert directement depuis le disque
> (erreur *Cross-Origin Request*, page blanche). Il faut donc ouvrir les fichiers XML
> **via un serveur local**, par exemple :
>
> - avec l'extension **Live Server** de Visual Studio Code (bouton *Go Live*) ;
> - ou avec la commande `python -m http.server` lancée dans le dossier du projet.

## 7. Résultats

### 7.1 Tableaux HTML (`meteo-dtd.xml` + `meteo-html.xsl`)

Un tableau **Ville / Température** est généré pour chaque date. Les températures sont
colorées selon leur valeur : **orange** (25° et plus, chaud), **vert** (de 20° à 24°, doux)
et **bleu** (moins de 20°, frais).

**Mesure du 1er janvier 2006**

![Tableau HTML - date 2006-1-1](captures/01-tableau-html-date1.png)

**Mesure du 2 janvier 2006** (avec la légende des couleurs)

![Tableau HTML - date 2006-1-2](captures/02-tableau-html-date2.png)

### 7.2 Histogramme SVG (`meteo-xsd.xml` + `meteo-svg.xsl`)

Pour chaque ville, deux barres sont dessinées : une **bleue** pour le 01-01-2006 et une
**orange** pour le 02-01-2006. La hauteur d'une barre est proportionnelle à la température.
Les barres apparaissent avec une petite animation au chargement, et une légende
indique la couleur de chaque date.

![Histogramme SVG des températures](captures/03-histogramme-svg.png)

## 8. Conclusion

Ce projet montre le rôle de chaque technologie XML :

- la **DTD** et le **XML Schema** décrivent et contrôlent la structure des données
  (le XML Schema ajoute des types : entier, date) ;
- **XSLT** transforme les mêmes données en formats d'affichage différents (HTML et SVG),
  sans modifier le document XML d'origine ;
- **XPath** permet de naviguer dans le document et de relier les mesures entre elles
  (`ville[@nom=$n]`) ;
- le **CSS** améliore la présentation de la page HTML.