FILES DA UTILIZZARE NEL SITO STATICO

sitemapGenerator.sh (da copiare nella root del repository)

    per l'indicizzazione del contenuto di tutte le pagine

    genera automaticamente la mappa del sito a partire dal file static.xml, da costruire manualmente se non esiste già e che dovrà contenere le pagine statiche, e dalla struttura dei dati generati

    bisogna poi 'informare' Goggle Console della presenza della sitemap.xml

dailySinc
opp.
dailySincAndSitemapUpdate

    queste sono 'actions' che inserite nel repository del sito, giornalmente aggiornano i dati generati e la sitemap

    crea una directory .github/workflows nella root del repository

    aggiungi il file nella directory, commit e push to github

    