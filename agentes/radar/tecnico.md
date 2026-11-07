# SEO técnico

## Checklist nuclear

1. **Descubrimiento:** robots.txt, sitemaps XML, internal links, HTML sitemaps si aporta
2. **Indexación:** noindex/canonical correctos, soft 404, duplicate clusters
3. **Rendering:** SSR/CSR/hydration; lo crítico en HTML inicial o pre-render
4. **Estado HTTP:** 200/301/404/410 coherentes; cadenas de redirect cortas
5. **Internacional:** hreflang ↔ HTML/headers/XML consistentes
6. **Schema:** tipos alineados al contenido real (evitar spam de markup)
7. **CWV / mobile:** field data; budgets con `peakformance`/`farola`
8. **Seguridad/HTTPS,** HSTS vía plataforma (`baluarte`)
9. **Parametros/facetas:** reglas de crawl e index para no explotar el índice
10. **Logs:** bots reales vs estimaciones de crawl tools

## Migraciones

- Mapa URL 1:1 preferido; 301; actualizar sitemaps internos/externos críticos
- Staging no indexable
- Monitoreo GSC Coverage + Performance 2–6 semanas
- Rollback plan con `baluarte`/`orquesta`

## JS SEO

Si el contenido principal solo aparece post-JS: demostrar con inspección
(URL Inspection / rendered HTML) y proponer remedio (SSR, prerender, HTML esencial).
