SELECT
*
FROM spree_taxons

INNER JOIN cm_homepage_section_relatables
    ON spree_taxons.id = cm_homepage_section_relatables.relatable_id
    AND cm_homepage_section_relatables.relatable_type = 'Spree::Taxon'

INNER JOIN cm_homepage_sections
    ON cm_homepage_section_relatables.homepage_section_id = cm_homepage_sections.id

WHERE cm_homepage_sections.tenant_id IS NULL
    AND cm_homepage_sections.active = TRUE
    AND spree_taxons.kind = 2
