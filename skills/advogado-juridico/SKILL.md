---
name: advogado-juridico
description: Legal advisor for drafting, analyzing, and reviewing legal documents. Use when the user says "draft a contract", "analyze this clause", "create an NDA", "review terms of service", "help with legal document", or asks about legal templates in Portuguese or English.
metadata:
  author: misaelholanda
  version: "1.0.0"
---

# Advogado Jurídico (Legal Advisor)

AI-powered legal advisor for drafting, analyzing, and reviewing legal documents. Supports both Portuguese (Brazilian law) and English (common law) contexts.

## How It Works

1. Identify the document type the user needs (contract, NDA, ToS, privacy policy, etc.)
2. Gather required parties, jurisdiction, and key terms from the user
3. Run the appropriate script to generate a structured document template
4. Present the filled template with placeholders clearly marked for user review
5. Offer to analyze or refine specific clauses on request

## Usage

```bash
# Generate a legal document template
bash /mnt/skills/user/advogado-juridico/scripts/generate-document.sh <type> [lang]

# Analyze an existing legal document
bash /mnt/skills/user/advogado-juridico/scripts/analyze-document.sh <file> [lang]

# List available document types
bash /mnt/skills/user/advogado-juridico/scripts/generate-document.sh --list
```

**Arguments — generate-document.sh:**
- `type` - Document type: `nda`, `service-contract`, `employment`, `privacy-policy`, `terms-of-service`, `lease`, `partnership`
- `lang` - Language/jurisdiction: `pt-BR` (default) or `en-US`

**Arguments — analyze-document.sh:**
- `file` - Path to the document file (`.txt`, `.md`, or `.pdf` text extraction)
- `lang` - Language hint: `pt-BR` (default) or `en-US`

**Examples:**
```bash
# Generate a Portuguese NDA template
bash /mnt/skills/user/advogado-juridico/scripts/generate-document.sh nda pt-BR

# Generate an English service contract
bash /mnt/skills/user/advogado-juridico/scripts/generate-document.sh service-contract en-US

# Analyze a contract file
bash /mnt/skills/user/advogado-juridico/scripts/analyze-document.sh ./contrato.txt pt-BR

# List all available templates
bash /mnt/skills/user/advogado-juridico/scripts/generate-document.sh --list
```

## Output

**generate-document.sh** outputs JSON:
```json
{
  "type": "nda",
  "lang": "pt-BR",
  "title": "Acordo de Confidencialidade (NDA)",
  "template": "...",
  "placeholders": ["PARTE_A", "PARTE_B", "DATA", "JURISDICAO"],
  "disclaimer": "Este documento é um modelo. Consulte um advogado licenciado antes de assinar."
}
```

**analyze-document.sh** outputs JSON:
```json
{
  "file": "contrato.txt",
  "lang": "pt-BR",
  "summary": "...",
  "clauses": [...],
  "risks": [...],
  "suggestions": [...],
  "disclaimer": "Esta análise é informativa. Consulte um advogado licenciado para orientação jurídica."
}
```

## Present Results to User

After generating a template, present it like this:

```
## [Document Title]

[Template content with placeholders highlighted in **bold**]

---
**Placeholders to fill in:**
- **PARTE_A** — Full legal name of Party A
- **PARTE_B** — Full legal name of Party B
- **DATA** — Effective date (DD/MM/YYYY)
- **JURISDICAO** — Governing jurisdiction

> ⚠️ This is a template for reference only. Have a licensed attorney review before signing.
```

After analyzing a document, present risks and suggestions as a structured list grouped by severity (High / Medium / Low).

## Supported Document Types

| Type | Portuguese | English |
|------|-----------|---------|
| `nda` | Acordo de Confidencialidade | Non-Disclosure Agreement |
| `service-contract` | Contrato de Prestação de Serviços | Service Agreement |
| `employment` | Contrato de Trabalho | Employment Contract |
| `privacy-policy` | Política de Privacidade (LGPD) | Privacy Policy (GDPR/CCPA) |
| `terms-of-service` | Termos de Uso | Terms of Service |
| `lease` | Contrato de Locação | Lease Agreement |
| `partnership` | Acordo de Parceria | Partnership Agreement |

## Troubleshooting

### File not found (analyze-document.sh)
Make sure the file path is absolute or relative to the current working directory. PDF analysis requires the text to be extractable (not scanned images).

### Unknown document type
Run with `--list` to see all supported types:
```bash
bash /mnt/skills/user/advogado-juridico/scripts/generate-document.sh --list
```

### Legal disclaimer
This skill produces reference templates and informational analysis only. It does not constitute legal advice. Always have a licensed attorney review documents before execution.
