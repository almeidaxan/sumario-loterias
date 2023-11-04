# library(pacman)

# p_load(dplyr)
# p_load(glue)
# p_load(RSelenium)
# p_load(tidyverse)
# p_load(wdman)
# p_load_gh("almeidaxan/insertPipe")


# TODO: Error handling quando `dr$navigate(url)` retorna um popup de
# erro 503 (rodar várias vezes para "duplasena" que uma hora aparece)
# TODO: Guardar data do próximo concurso
# TODO: Guardar prêmio esperado vs. investimento
# TODO: Estruturar num df e apresentá-lo


chrome_server <- wdman::chrome(version = "97.0.4692.71")

dr <- remoteDriver(
  remoteServerAddr = "localhost", port = 4567L, browserName = "chrome"
)

dr$open(silent = TRUE)

concursos <- c(
    "megasena", "lotofacil", "diadesorte", "quina", "lotomania", "timemania",
    "duplasena", "supersete"
    )

for (concurso in concursos) {
   url <- glue("http://loterias.caixa.gov.br/wps/portal/loterias/landing/{concurso}")

   dr$navigate(url)

   tryCatch(
      elem <- dr$findElements(
          using = "css selector", value = "p.value.ng-binding"
    ),
      error = function(e) {
         print("Erro")
         dr$acceptAlert()
         invisible(e)
      }
   )

   estimativa_premio <- elem[[1]]$getElementText()[[1]]

   print(glue("{concurso}: {estimativa_premio}"))
}

dr$close()


# Preços

# TODO: Fazer scrape.
bet_prices <- tibble(
    concurso = concursos,
    preco = c(4.5, 2.5, 2.0, 2.0, 2.5, 3.0, 2.5, 2.5)
    )


# Prob de acertos (1 em ...)

# Megasena
round(1 / dhyper(4:6, m = 6, n = 54, k = 6), 0)

# Loto Fácil
round(1 / dhyper(11:15, m = 15, n = 10, k = 15), 0)

# Dia de Sorte
round(1 / dhyper(4:7, m = 7, n = 24, k = 7), 0)
12 # Mês de Sorte (premiação independente)

# Quina
round(1 / dhyper(2:5, m = 5, n = 75, k = 5), 0)

# Lotomania
round(1 / dhyper(c(0, 15:20), m = 20, n = 80, k = 50), 0)

# Timemania
round(1 / dhyper(3:7, m = 7, n = 73, k = 10), 0)
80 # Time do coração (premiação independente)

# Duplasena (2 sorteios independentes)
round(1 / dhyper(3:6, m = 6, n = 44, k = 6), 0) / 2

# Super Sete
round(1 / dbinom(3:7, size = 7, prob = 0.1), 1)
