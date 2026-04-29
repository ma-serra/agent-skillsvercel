#!/bin/bash
set -e

FILE="${1:-}"
LANG="${2:-pt-BR}"

cleanup() {
  rm -f /tmp/advogado-analyze-$$.tmp 2>/dev/null || true
}
trap cleanup EXIT

if [[ -z "$FILE" ]]; then
  echo '{"error":"Missing file argument. Usage: analyze-document.sh <file> [lang]"}' >&2
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "{\"error\":\"File not found: $FILE\"}" >&2
  exit 1
fi

EXT="${FILE##*.}"
echo "Reading document: $FILE (.$EXT)..." >&2

case "$EXT" in
  txt|md|markdown)
    CONTENT=$(cat "$FILE")
    ;;
  pdf)
    if command -v pdftotext &>/dev/null; then
      CONTENT=$(pdftotext "$FILE" - 2>/dev/null)
    else
      echo '{"error":"pdftotext not found. Install poppler-utils to analyze PDF files, or convert to .txt first."}' >&2
      exit 1
    fi
    ;;
  *)
    CONTENT=$(cat "$FILE" 2>/dev/null || true)
    if [[ -z "$CONTENT" ]]; then
      echo "{\"error\":\"Unsupported file type: .$EXT. Use .txt, .md, or .pdf.\"}" >&2
      exit 1
    fi
    ;;
esac

WORD_COUNT=$(echo "$CONTENT" | wc -w)
LINE_COUNT=$(echo "$CONTENT" | wc -l)
CHAR_COUNT=${#CONTENT}

echo "Document stats: $WORD_COUNT words, $LINE_COUNT lines" >&2

if [[ "$LANG" == "pt-BR" ]]; then
  DISCLAIMER="Esta análise é informativa e não constitui aconselhamento jurídico. Consulte um advogado licenciado para orientação jurídica."
  SUMMARY_NOTE="Análise automática do documento"
else
  DISCLAIMER="This analysis is informational and does not constitute legal advice. Consult a licensed attorney for legal guidance."
  SUMMARY_NOTE="Automated document analysis"
fi

python3 - <<PYEOF
import json, re, sys

content = """$CONTENT"""
lang = "$LANG"
file_path = "$FILE"
word_count = $WORD_COUNT
line_count = $LINE_COUNT

# Heuristic clause detection
clause_patterns_ptbr = [
    r'(?i)\b(cl[aá]usula|art(?:igo)?\.?\s*\d+|§\s*\d+)\b',
    r'(?i)\b(objeto|prazo|vig[eê]ncia|remunera[cç][aã]o|pagamento|rescis[aã]o|foro|penalidade|multa|obriga[cç][aã]o|confidencialidade|sigilo|propriedade intelectual)\b'
]
clause_patterns_enus = [
    r'(?i)\b(clause|section|article|§)\s*\d+',
    r'(?i)\b(term|payment|termination|governing law|indemnification|limitation of liability|confidentiality|intellectual property|warranties|representations)\b'
]

patterns = clause_patterns_ptbr if lang == "pt-BR" else clause_patterns_enus

found_topics = set()
for pattern in patterns:
    matches = re.findall(pattern, content)
    for m in matches:
        if isinstance(m, tuple):
            found_topics.update(t.strip().lower() for t in m if t.strip())
        else:
            found_topics.add(m.strip().lower())

clauses = sorted(list(found_topics))[:20]

# Heuristic risk detection
risks = []

if lang == "pt-BR":
    if re.search(r'(?i)(prazo\s+indeterminado|sem\s+prazo\s+definido)', content):
        risks.append({"severity": "medium", "description": "Contrato sem prazo definido — pode gerar insegurança jurídica."})
    if not re.search(r'(?i)(foro|jurisdi[cç][aã]o|comarca)', content):
        risks.append({"severity": "high", "description": "Ausência de cláusula de eleição de foro — litígios podem ser ajuizados em qualquer jurisdição."})
    if not re.search(r'(?i)(rescis[aã]o|termina[cç][aã]o)', content):
        risks.append({"severity": "high", "description": "Ausência de cláusula de rescisão — não há mecanismo claro para encerrar o contrato."})
    if re.search(r'(?i)(exclusividade|exclusive)', content):
        risks.append({"severity": "medium", "description": "Cláusula de exclusividade detectada — verifique o escopo e prazo da exclusividade."})
    if not re.search(r'(?i)(multa|penalidade|indeniza[cç][aã]o)', content):
        risks.append({"severity": "low", "description": "Ausência de penalidades por descumprimento — considere adicionar cláusula penal."})
else:
    if re.search(r'(?i)(unlimited liability|no cap on liability)', content):
        risks.append({"severity": "high", "description": "Unlimited liability clause detected — consider negotiating a liability cap."})
    if not re.search(r'(?i)(governing law|jurisdiction)', content):
        risks.append({"severity": "high", "description": "No governing law clause — disputes may be litigated in any jurisdiction."})
    if not re.search(r'(?i)(termination|cancellation)', content):
        risks.append({"severity": "high", "description": "No termination clause — no clear mechanism to end the agreement."})
    if re.search(r'(?i)(exclusivity|exclusive)', content):
        risks.append({"severity": "medium", "description": "Exclusivity clause detected — review scope and duration carefully."})
    if not re.search(r'(?i)(indemnif|penalty|liquidated damages)', content):
        risks.append({"severity": "low", "description": "No penalty or indemnification clause — consider adding breach remedies."})

if lang == "pt-BR":
    suggestions = [
        "Revise os prazos e datas para garantir que estão corretos e exequíveis.",
        "Certifique-se de que todas as partes estão identificadas com CNPJ/CPF válidos.",
        "Verifique se o contrato está em conformidade com a legislação vigente (CC, CLT, LGPD conforme aplicável).",
        "Considere adicionar cláusula de mediação/arbitragem antes do foro judicial.",
        "Tenha o documento assinado por duas testemunhas para maior validade."
    ]
else:
    suggestions = [
        "Review all dates and deadlines to ensure they are accurate and enforceable.",
        "Ensure all parties are properly identified with full legal names and entity types.",
        "Verify compliance with applicable law (UCC, state statutes, GDPR/CCPA as relevant).",
        "Consider adding an alternative dispute resolution (ADR/arbitration) clause.",
        "Have the document reviewed by a licensed attorney in the governing jurisdiction."
    ]

result = {
    "file": file_path,
    "lang": lang,
    "stats": {
        "words": word_count,
        "lines": line_count
    },
    "summary": "$SUMMARY_NOTE" + f" — {word_count} words, {len(clauses)} key topics detected.",
    "detected_topics": clauses,
    "risks": risks,
    "suggestions": suggestions,
    "disclaimer": "$DISCLAIMER"
}

print(json.dumps(result, ensure_ascii=False, indent=2))
PYEOF
