#!/usr/bin/env bash
set -euo pipefail

# Nome do ambiente (mudar aqui se preferir)
ENV_NAME="qsim-env"

# Lista de nomes de ficheiro base a tentar (ordem de preferência)
DEFAULT_BASE_CANDIDATES=("environment-base.yml" "environment.yml" "environment-base.yaml" "environment.yaml")

usage() {
  cat <<EOF
Uso: $(basename "$0") <overlay-OS.yml> [overlay-GPU.yml]
Nota: ao passar apenas o nome do arquivo (ex: environment-linux.yml), o script
      procura os arquivos em $(pwd) (diretório de execução), NÃO no diretório do script.

Exemplos:
  ./create-env.sh environment-linux.yml
  ./create-env.sh environment-linux.yml environment-gpu.yml
  ./create-env.sh /caminho/para/environment.yml /caminho/para/environment-gpu.yml
EOF
  exit 1
}

# Verifica argumentos
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage
fi

OS_YML_INPUT="$1"
GPU_YML_INPUT="${2:-}"

# Função para normalizar caminho:
# - se for caminho absoluto ou contém '/', usa como foi passado
# - se for somente nome de arquivo, transforma em "$PWD/<nome>"
resolve_path() {
  local input="$1"
  if [ -z "$input" ]; then
    echo ""
    return
  fi
  # Se começar com / ou com ~ ou contém '/', assume caminho fornecido (expande ~)
  if [[ "$input" = /* ]] || [[ "$input" == ~* ]] || [[ "$input" == */* ]]; then
    if [[ "$input" == ~* ]]; then
      eval echo "$input"
    else
      echo "$input"
    fi
  else
    echo "${PWD%/}/$input"
  fi
}

# Função que procura um ficheiro base entre candidatos e retorna path resolvido (ou vazio)
find_base_yaml() {
  for name in "${DEFAULT_BASE_CANDIDATES[@]}"; do
    local candidate
    candidate="$(resolve_path "$name")"
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  # não encontrou
  echo ""
  return 1
}

# Primeiro tenta encontrar um base file entre os candidatos
BASE_YML_PATH="$(find_base_yaml || true)"

# Se não encontrou nenhum base file, faz fallback para variável de ambiente BASE_YML_OVERRIDE (opcional)
if [ -z "$BASE_YML_PATH" ] && [ -n "${BASE_YML_OVERRIDE:-}" ]; then
  BASE_YML_PATH="$(resolve_path "$BASE_YML_OVERRIDE")"
fi

# Se ainda não encontrou, erro explicativo
if [ -z "$BASE_YML_PATH" ]; then
  echo "ERRO: nenhum ficheiro base encontrado."
  echo "Procurei por: ${DEFAULT_BASE_CANDIDATES[*]} no diretório atual ($(pwd))."
  echo "Se o seu ficheiro base tem outro nome, passe o caminho absoluto como variável de ambiente BASE_YML_OVERRIDE,"
  echo "por ex:"
  echo "  BASE_YML_OVERRIDE=/caminho/para/meu-env.yml ./create-env.sh environment-linux.yml"
  exit 3
fi

OS_YML_PATH="$(resolve_path "$OS_YML_INPUT")"
GPU_YML_PATH=""
if [ -n "$GPU_YML_INPUT" ]; then
  GPU_YML_PATH="$(resolve_path "$GPU_YML_INPUT")"
fi

# Verificações iniciais
if ! command -v conda >/dev/null 2>&1; then
  echo "ERRO: 'conda' não foi encontrado no PATH. Ative o conda ou instale Miniconda/Anaconda."
  exit 2
fi

if [ ! -f "$BASE_YML_PATH" ]; then
  echo "ERRO: ficheiro base '${BASE_YML_PATH}' não encontrado (verificação final)."
  exit 3
fi

if [ ! -f "$OS_YML_PATH" ]; then
  echo "ERRO: ficheiro de overlay do SO '${OS_YML_PATH}' não encontrado."
  exit 4
fi

if [ -n "$GPU_YML_PATH" ] && [ ! -f "$GPU_YML_PATH" ]; then
  echo "ERRO: ficheiro de overlay GPU '${GPU_YML_PATH}' não encontrado."
  exit 5
fi

echo "=== Arquivos usados ==="
echo "Base (detectado): $BASE_YML_PATH"
echo "Overlay SO:       $OS_YML_PATH"
if [ -n "$GPU_YML_PATH" ]; then
  echo "Overlay GPU:      $GPU_YML_PATH"
fi
echo "======================="

# Criar/atualizar ambiente
if conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  echo "Ambiente '${ENV_NAME}' já existe. Atualizando com ${BASE_YML_PATH}..."
  conda env update -n "$ENV_NAME" -f "$BASE_YML_PATH"
else
  echo "Ambiente '${ENV_NAME}' não existe. Criando a partir de ${BASE_YML_PATH}..."
  conda env create -f "$BASE_YML_PATH"
fi

echo "=== Aplicando overlay de SO: ${OS_YML_PATH}
