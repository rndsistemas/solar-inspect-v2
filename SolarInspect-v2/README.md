# SOLAR INSPECT — versão corrigida

Protótipo funcional para inspeção e manutenção de módulos fotovoltaicos.

## Principais correções

- tratamento de dados locais corrompidos;
- tratamento de limite de armazenamento do navegador;
- imagens reduzidas para diminuir o risco de estourar o `localStorage`;
- service worker atualizado para não armazenar indiscriminadamente tiles e recursos externos;
- fallback offline aplicado somente à navegação HTML;
- versão de cache alterada para evitar arquivos antigos presos no navegador;
- tratamento de falha no carregamento do Leaflet/mapa;
- limite de zoom ajustado ao OpenStreetMap padrão;
- melhorias de responsividade no cabeçalho e painel;
- compatibilidade com dados salvos pela versão anterior.

## Executar

Na pasta do projeto:

```bash
python -m http.server 8080
```

Depois acesse `http://localhost:8080`.

> Evite abrir diretamente com `file://`, pois service worker e geolocalização dependem de contexto seguro/servidor HTTP.

## Observação

O mapa ainda usa Leaflet e OpenStreetMap pela internet. A interface principal fica em cache, mas o mapa base não é garantido offline. Para operação de campo 100% offline, é necessário empacotar o Leaflet localmente e definir uma fonte de mapas offline.
