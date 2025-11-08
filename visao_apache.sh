#!/bin/bash

# Visao_Apache - Projeto de código aberto
# Copyright (C) 2025 Luan Calazans
# Licenciado sob a GNU AGPL v3. Veja o arquivo LICENSE para mais detalhes.
# Contato: https://www.linkedin.com/in/luan-bsc

VERSION="0.7.2"
LOG_FORMAT='^([0-9.]+) - - \[(.*?)\] "(.*?)" ([0-9]+) ([0-9]+) "(.*?)" "(.*?)"'

ORANGE='\033[0;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

nome_arquivo=""
temp_dir="/tmp/visao_apache"
cache_file="$temp_dir/cache_$$.tmp"

mkdir -p "$temp_dir"

cleanup() {
    rm -f "$cache_file"
    exit 0
}
trap cleanup EXIT INT TERM

pula_linha() {
    local num=$1
    for ((i=1; i<=num; i++)); do
        echo ""
    done
}

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        "INFO") echo -e "${GREEN}[$timestamp] INFO: $message${NC}" ;;
        "WARN") echo -e "${YELLOW}[$timestamp] WARN: $message${NC}" ;;
        "ERROR") echo -e "${RED}[$timestamp] ERROR: $message${NC}" ;;
    esac
}

validate_log_file() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "Arquivo $file não encontrado"
        return 1
    fi

    if [[ ! -r "$file" ]]; then
        log_message "ERROR" "Sem permissão de leitura para $file"
        return 1
    fi

    if [[ ! -s "$file" ]]; then
        log_message "ERROR" "Arquivo $file está vazio"
        return 1
    fi

    if ! head -1 "$file" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'; then
        log_message "WARN" "O arquivo pode não estar no formato de log Apache esperado"
    fi

    return 0
}

cache_data() {
    local key=$1
    local data=$2
    echo "$data" > "${cache_file}_${key}"
}

get_cached_data() {
    local key=$1
    local cache_file="${cache_file}_${key}"
    if [[ -f "$cache_file" && -s "$cache_file" ]]; then
        cat "$cache_file"
        return 0
    fi
    return 1
}

# Interface
logo() {
    clear
    pula_linha 2
    echo -e "${YELLOW}                                   ?  Bem vindo !${NC}"
    pula_linha 1
    echo -e "${YELLOW}                         ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣤⣤⣤⣤⣤⣤⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀${NC}"
    echo -e "${YELLOW}                         ⠀⠀⠀⠀⠀⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣄⠀⠀⠀⠀⠀⠀${NC}"
    echo -e "${YELLOW}                         ⠀⠀⠀⣠⣶⣿⣿⡿⣿⣿⣿⡿⠋⠉⠀⠀⠉⠙⢿⣿⣿⡿⣿⣿⣷⣦⡀⠀⠀⠀${NC}"
    echo -e "${YELLOW}                         ⠀⢀⣼⣿⣿⠟⠁⢠⣿⣿⠏⠀⠀⢠⣤⣤⡀⠀⠀⢻⣿⣿⡀⠙⢿⣿⣿⣦⠀⠀${NC}"
    echo -e "${YELLOW}                         ⣰⣿⣿⡟⠁⠀⠀⢸⣿⣿⠀⠀⠀⢿⣿⣿⡟⠀⠀⠈⣿⣿⡇⠀⠀⠙⣿⣿⣷        ~ v${VERSION} ~ Alpha    ${NC}"
    echo -e "${YELLOW}                         ⠈⠻⣿⣿⣦⣄⠀⠸⣿⣿⣆⠀⠀⠀⠉⠉⠀⠀⠀⣸⣿⣿⠃⢀⣤⣾⣿⣿⠟⠁${NC}"
    echo -e "${YELLOW}                         ⠀⠀⠈⠻⣿⣿⣿⣶⣿⣿⣿⣦⣄⠀⠀⠀⢀⣠⣾⣿⣿⣿⣾⣿⣿⡿⠋⠁⠀⠀${NC}"
    echo -e "${YELLOW}                         ⠀⠀⠀⠀⠀⠙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠁⠀⠀⠀⠀⠀${NC}"
    echo -e "${YELLOW}                        ⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠿⠿⠿⠿⠿⠿⠿⠛⠋⠉⠀⠀⠀⠀⠀⠀${NC}"
    pula_linha 1
    echo -e "${YELLOW}                         - = - = - = visão Apache 2 - = - = - =${NC}"
    pula_linha 2
}

nome_app() {
    echo -e "${RED}    ▄   ▄█    ▄▄▄▄▄   ██   ████▄     ██   █ ▄▄  ██   ▄█▄     ▄  █ ▄███▄   ${NC}"
    echo -e "${RED}     █  ██   █     ▀▄ █ █  █   █     █ █  █   █ █ █  █▀ ▀▄  █   █ █▀   ▀  ${NC}"
    echo -e "${RED}█     █ ██ ▄  ▀▀▀▀▄   █▄▄█ █   █     █▄▄█ █▀▀▀  █▄▄█ █   ▀  ██▀▀█ ██▄▄    ${NC}"
    echo -e "${RED} █    █ ▐█  ▀▄▄▄▄▀    █  █ ▀████     █  █ █     █  █ █▄  ▄▀ █   █ █▄   ▄▀ ${NC}"
    echo -e "${RED}  █  █   ▐               █              █  █       █ ▀███▀     █  ▀███▀   ${NC}"
    echo -e "${RED}   █▐                   █              █    ▀     █           ▀             ${NC}"
    echo -e "${RED}   ▐                   ▀              ▀          ▀                         ${NC}"
}

adicionar_arquivo() {
    while true; do
        logo
        echo -e "${GREEN}Selecione uma opção:${NC}"
        echo "1. Usar arquivo no diretório atual"
        echo "2. Especificar caminho completo"
        echo "3. Voltar"
        pula_linha 1
        read -p "Opção: " opcao_arquivo

        case $opcao_arquivo in
            1)
                echo -e "${GREEN}Arquivos .log no diretório atual:${NC}"
                ls -1 *.log 2>/dev/null || echo -e "${YELLOW}Nenhum arquivo .log encontrado${NC}"
                pula_linha 1
                read -p "Digite o nome do arquivo: " nome_arquivo
                ;;
            2)
                read -p "Digite o caminho completo do arquivo: " nome_arquivo
                ;;
            3)
                return 1
                ;;
            *)
                echo -e "${RED}Opção inválida${NC}"
                sleep 2
                continue
                ;;
        esac

        if validate_log_file "$nome_arquivo"; then
            log_message "INFO" "Arquivo $nome_arquivo carregado com sucesso"
            pula_linha 1
            echo -e "${GREEN}Primeira linha do arquivo:${NC}"
            head -n 1 "$nome_arquivo"
            sleep 3
            return 0
        else
            echo -e "${RED}Erro ao carregar arquivo. Tente novamente.${NC}"
            sleep 3
        fi
    done
}

exibir_menu() {
    clear
    nome_app
    pula_linha 2
    echo -e "${CYAN}ARQUIVO ATUAL: ${YELLOW}$nome_arquivo${NC}"
    pula_linha 1
    echo -e "${GREEN}Menu Principal:${NC}"
    echo -e "${RED}"
    echo "                1.   Informações do arquivo"
    echo "                2.   Análise de IP's"
    echo "                3.   Códigos de status HTTP"
    echo "                4.   URLs mais acessadas"
    echo "                5.   Métodos por IP"
    echo "                6.   IPs suspeitos (+50 requisições)"
    echo "                7.   Análise de User-Agents"
    echo "                8.   Referências"
    echo "                9.   Buscar padrões suspeitos"
    echo "                10.  Estatísticas avançadas"
    echo "                11.  Detecção de Scanners"
    echo "                12.  Análise Geográfica"
    echo "                13.  Detecção DDoS"
    echo "                14.  Crawlers Legítimos"
    echo "                15.  Path Traversal"
    echo "                16.  Análise de Sessões"
    echo "                17.  Detecção Data Leakage"
    echo "                18.  Análise Performance"
    echo "                19.  Detecção Web Shells"
    echo "                20.  Fingerprinting"
    echo "                21.  Análise API"
    echo "                22.  Credential Stuffing"
    echo "                23.  Mobile vs Desktop"
    echo "                24.  Informações /etc/passwd"
    echo "                25.  Investigar por Data"
    echo "                26.  Análise de Payloads"
    echo "                27.  Análise de Redirecionamentos"
    echo "                28.  Detecção de Port Scan"
    echo "                29.  Exportar Relatório"
    echo "                30.  Help / Sobre"
    echo "                0.   Sair"
    echo -e "${NC}"
    pula_linha 1
}

contagem_linhas_arq() {
    clear
    local cache_key="file_info"

    if get_cached_data "$cache_key"; then
        return
    fi

    echo -e "${RED}"
    pula_linha 1
    echo "════════════════════════════ INFORMAÇÕES DO ARQUIVO ════════════════════════════"
    pula_linha 1

    local num_linhas=$(wc -l < "$nome_arquivo")
    local tamanho=$(du -h "$nome_arquivo" | cut -f1)
    local primeira_data=$(head -1 "$nome_arquivo" | awk '{print $4}' | cut -d'[' -f2)
    local ultima_data=$(tail -1 "$nome_arquivo" | awk '{print $4}' | cut -d'[' -f2)

    echo -e "Linhas: ${YELLOW}$num_linhas${NC}"
    echo -e "Tamanho: ${YELLOW}$tamanho${NC}"
    echo -e "Período: ${YELLOW}$primeira_data${NC} até ${YELLOW}$ultima_data${NC}"

    pula_linha 1
    echo -e "${CYAN}Estatísticas:${NC}"
    awk '
    {
        sum += $10;
        count++;
        if ($10 > max) max = $10;
        if (NR==1) min = $10;
        if ($10 < min) min = $10;
    }
    END {
        if (count > 0) {
            print "Tempo de resposta - Média: " sum/count "s"
            print "Tempo de resposta - Máximo: " max "s"
            print "Tempo de resposta - Mínimo: " min "s"
        }
    }' "$nome_arquivo"

    pula_linha 1
    echo -e "${CYAN}Top 5 métodos HTTP:${NC}"
    awk '{print $6}' "$nome_arquivo" | sed 's/"//g' | sort | uniq -c | sort -nr | head -5

    cache_data "$cache_key" "done"

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

buscar_ips() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════════ ANÁLISE DE IP's ═══════════════════════════════"
    pula_linha 1

    echo -e "${CYAN}IP's únicos encontrados:${NC}"
    awk '{print $1}' "$nome_arquivo" | sort -u | head -20

    pula_linha 1
    echo -e "${CYAN}Top 20 IP's por requisições:${NC}"
    awk '{print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -20

    pula_linha 1
    echo -e "${CYAN}Requisições por hora (Top 20):${NC}"
    awk '{print $4}' "$nome_arquivo" | cut -d: -f2 | sort | uniq -c | sort -nr | head -20

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

distribuicao_codigos_status() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ CÓDIGOS DE STATUS HTTP ═══════════════════════════"
    pula_linha 1

    echo -e "${CYAN}Distribuição detalhada:${NC}"
    awk '{print $9}' "$nome_arquivo" | sort | uniq -c | sort -nr | while read count code; do
        case $code in
            2*) color=$GREEN ;;
            3*) color=$YELLOW ;;
            4*) color=$RED ;;
            5*) color=$RED ;;
            *) color=$NC ;;
        esac
        echo -e "${color}$count x Código $code${NC}"
    done

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

urls_mais_acessadas() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "═══════════════════════════ URLS MAIS ACESSADAS ═════════════════════════════"
    pula_linha 1

    echo -e "${CYAN}Top 20 URLs:${NC}"
    awk '{print $7}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -20

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

metodos_por_ip() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ MÉTODOS POR IP ═══════════════════════════════════"
    pula_linha 1

    echo -e "${CYAN}Top 20 combinações IP/Método:${NC}"
    awk '{print $1, $6}' "$nome_arquivo" | sed 's/"//g' | sort | uniq -c | sort -nr | head -20

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

ips_suspeitos() {
    clear
    local threshold=${1:-50}

    echo -e "${RED}"
    pula_linha 1
    echo "═══════════════════════════ IP's SUSPEITOS (+$threshold req) ═══════════════════════════"
    pula_linha 1

    echo -e "${RED}IPs com mais de $threshold requisições:${NC}"
    awk '{print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | awk -v threshold=$threshold '$1 > threshold'

    pula_linha 1
    echo -e "${YELLOW}Total de IPs analisados:${NC}"
    awk '{print $1}' "$nome_arquivo" | sort -u | wc -l

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

vizualizador_trafego() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ ANÁLISE DE USER-AGENTS ═══════════════════════════"
    pula_linha 1

    echo -e "${CYAN}Top 20 User-Agents:${NC}"
    awk -F\" '{print $6}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -20

    pula_linha 1
    echo -e "${CYAN}Distribuição por tipo:${NC}"
    echo -e "${GREEN}Navegadores:${NC}"
    awk -F\" '{print $6}' "$nome_arquivo" | grep -i -E "chrome|firefox|safari|edge" | wc -l
    echo -e "${YELLOW}Bots/Crawlers:${NC}"
    awk -F\" '{print $6}' "$nome_arquivo" | grep -i -E "bot|crawler|spider" | wc -l
    echo -e "${RED}Outros:${NC}"
    awk -F\" '{print $6}' "$nome_arquivo" | grep -v -i -E "chrome|firefox|safari|edge|bot|crawler|spider" | wc -l

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

verificar_referers() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════════ REFERÊNCIAS ═══════════════════════════════════"
    pula_linha 1

    echo -e "${CYAN}Top 20 referências:${NC}"
    awk -F\" '{print $4}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -20

    pula_linha 1
    echo -e "${CYAN}Requisições sem referência:${NC}"
    awk -F\" '$4 == "-"' "$nome_arquivo" | wc -l

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

buscar_padroes_suspeitos() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ PADRÕES SUSPEITOS ════════════════════════════════"
    pula_linha 1

    echo -e "${RED}Possíveis tentativas de invasão:${NC}"

    local patterns=(
        "etc/passwd"
        "bin/sh"
        "cmd.exe"
        "union.select"
        "script.php"
        "web.config"
        "admin.php"
        "wp-admin"
        "eval("
        "base64_decode"
    )

    for pattern in "${patterns[@]}"; do
        count=$(grep -i "$pattern" "$nome_arquivo" | wc -l)
        if [[ $count -gt 0 ]]; then
            echo -e "${RED}Padrão '$pattern': $count ocorrências${NC}"
        fi
    done

    pula_linha 1
    echo -e "${YELLOW}Requisições com user-agents suspeitos:${NC}"
    awk -F\" '{print $6}' "$nome_arquivo" | grep -i -E "nikto|sqlmap|nmap|metasploit" | uniq -c

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

estatisticas_avancadas() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ ESTATÍSTICAS AVANÇADAS ═══════════════════════════"
    pula_linha 1

    echo -e "${CYAN}Tráfego por dia:${NC}"
    awk '{print $4}' "$nome_arquivo" | cut -d: -f1 | cut -d[ -f2 | sort | uniq -c

    pula_linha 1
    echo -e "${CYAN}Top 10 páginas com erro 404:${NC}"
    awk '$9 == "404" {print $7}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -10

    pula_linha 1
    echo -e "${CYAN}Top 10 páginas com erro 500:${NC}"
    awk '$9 == "500" {print $7}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -10

    pula_linha 1
    echo -e "${CYAN}Distribuição por tamanho de resposta:${NC}"
    awk '
    {
        size = $10;
        if (size < 1024) small++;
        else if (size < 10240) medium++;
        else if (size < 1048576) large++;
        else huge++;
    }
    END {
        total = small + medium + large + huge;
        if (total > 0) {
            print "Pequenas (<1KB): " small " (" small/total*100 "%)"
            print "Médias (<10KB): " medium " (" medium/total*100 "%)"
            print "Grandes (<1MB): " large " (" large/total*100 "%)"
            print "Enormes (>=1MB): " huge " (" huge/total*100 "%)"
        }
    }' "$nome_arquivo"

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

detectar_scanners() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ DETECÇÃO DE SCANNERS ═══════════════════════════"
    pula_linha 1
    
    echo -e "${RED}Scanners de Vulnerabilidades:${NC}"
    local scanners=("nmap" "nikto" "sqlmap" "metasploit" "nessus" "openvas" "burp" "wpscan" "joomscan")
    
    for scanner in "${scanners[@]}"; do
        count=$(grep -i "$scanner" "$nome_arquivo" | wc -l)
        if [[ $count -gt 0 ]]; then
            echo -e "${RED}🔍 $scanner: $count requisições${NC}"
            grep -i "$scanner" "$nome_arquivo" | awk '{print $1}' | sort -u | head -3 | while read ip; do
                echo "   IP: $ip"
            done
        fi
    done
    
    pula_linha 1
    echo -e "${YELLOW}Padrões de Scanner Comuns:${NC}"
    grep -E "(admin|login|wp-admin|phpmyadmin|\.bak|\.old|\.txt)" "$nome_arquivo" | awk '{print $1, $7}' | sort -u | head -10
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

analise_geografica() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ ANÁLISE GEOGRÁFICA ═══════════════════════════"
    pula_linha 1
    
    echo -e "${CYAN}Top IPs por país (usando whois):${NC}"
    
    awk '{print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -5 | while read count ip; do
        country=$(whois "$ip" 2>/dev/null | grep -i country | head -1 | awk '{print $2}' | tr -d '\r')
        if [[ -z "$country" ]]; then
            country="Desconhecido"
        fi
        echo -e "IP: $ip - Requisições: $count - País: $country"
    done
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

detectar_ddos() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ DETECÇÃO DE DDoS ═══════════════════════════"
    pula_linha 1
    
    local threshold=100
    local ip_threshold=1000
    
    echo -e "${RED}Possíveis ataques DDoS (IPs com +$threshold req/min):${NC}"
    
    awk '{
        split($4, dt, ":"); 
        minuto = dt[1] ":" dt[2];
        print minuto, $1
    }' "$nome_arquivo" | sed 's/\[//g' | sort | uniq -c | \
    awk -v threshold=$threshold '$1 > threshold {print "Minuto: "$2", Requisições: "$1", IP: "$3}' | head -10
    
    pula_linha 1
    
    echo -e "${YELLOW}IPs com mais de $ip_threshold requisições (TOP 10):${NC}"
    awk '{print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -10 | \
    while read count ip; do
        if [[ $count -gt 5000 ]]; then
            echo -e "${RED}🚨 MASSIVO: $ip - $count requisições${NC}"
        elif [[ $count -gt 1000 ]]; then
            echo -e "${YELLOW}⚠️  ALTO: $ip - $count requisições${NC}"
        else
            echo -e "${GREEN}✅ NORMAL: $ip - $count requisições${NC}"
        fi
    done
    
    pula_linha 1
    
    echo -e "${RED}🔍 INVESTIGANDO IP MAIS SUSPEITO:${NC}"
    ip_suspeito=$(awk '{print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
    count_suspeito=$(awk '{print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
    
    if [[ -n "$ip_suspeito" && $count_suspeito -gt 1000 ]]; then
        echo -e "${RED}🚨 IP $ip_suspeito - $count_suspeito requisições (POSSÍVEL ATAQUE)${NC}"
        
        echo -e "${CYAN}Comportamento do IP $ip_suspeito:${NC}"
        
        echo -e "${YELLOW}Horários de pico:${NC}"
        awk -v ip="$ip_suspeito" '$1 == ip {print $4}' "$nome_arquivo" | cut -d: -f2 | sort | uniq -c | sort -nr | head -5
        
        echo -e "${YELLOW}URLs mais acessadas:${NC}"
        awk -v ip="$ip_suspeito" '$1 == ip {print $7}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -5
        
        echo -e "${YELLOW}Métodos HTTP:${NC}"
        awk -v ip="$ip_suspeito" '$1 == ip {print $6}' "$nome_arquivo" | sed 's/"//g' | sort | uniq -c | sort -nr
        
        echo -e "${YELLOW}Códigos de status:${NC}"
        awk -v ip="$ip_suspeito" '$1 == ip {print $9}' "$nome_arquivo" | sort | uniq -c | sort -nr
        
    else
        echo "Nenhum IP com comportamento suspeito detectado"
    fi
    
    pula_linha 1
    
    echo -e "${CYAN}📊 ANÁLISE DE PICOS HORÁRIOS:${NC}"
    awk '{print $4}' "$nome_arquivo" | cut -d: -f2 | sort | uniq -c | sort -nr | head -5 | \
    while read count hora; do
        if [[ $count -gt 1000 ]]; then
            echo -e "${RED}🚨 PICO: $hora h - $count requisições${NC}"
        else
            echo "Hora $hora: $count requisições"
        fi
    done
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    echo -e "${NC}"
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

analise_crawlers() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ CRAWLERS LEGÍTIMOS ═══════════════════════════"
    pula_linha 1
    
    local crawlers=(
        "googlebot" "bingbot" "yahoo" "duckduckbot" "baiduspider"
        "yandexbot" "facebookexternalhit" "twitterbot" "linkedinbot"
    )
    
    for crawler in "${crawlers[@]}"; do
        count=$(grep -i "$crawler" "$nome_arquivo" | wc -l)
        if [[ $count -gt 0 ]]; then
            echo -e "${GREEN}🤖 $crawler: $count requisições${NC}"
        fi
    done
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

detectar_path_traversal() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ PATH TRAVERSAL ═══════════════════════════"
    pula_linha 1
    
    local patterns=(
        "\.\." "\.\./" "\.\.\\" "%2e%2e" "%2e%2e%2f"
        "\.\.%2f" "\.\.%5c" "\.\.%255c"
    )
    
    for pattern in "${patterns[@]}"; do
        count=$(grep -i "$pattern" "$nome_arquivo" | wc -l)
        if [[ $count -gt 0 ]]; then
            echo -e "${RED}🚨 Path Traversal '$pattern': $count ocorrências${NC}"
            grep -i "$pattern" "$nome_arquivo" | awk '{print $1, $7}' | head -3
        fi
    done
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

analise_sessoes() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ ANÁLISE DE SESSÕES ═══════════════════════════"
    pula_linha 1
    
    echo -e "${CYAN}IPs com comportamento de sessão longa:${NC}"
    
    awk '{print $1, $7}' "$nome_arquivo" | sort -u | awk '{print $1}' | sort | uniq -c | sort -nr | head -10 | \
    while read count ip; do
        urls=$(awk -v ip="$ip" '$1 == ip {print $7}' "$nome_arquivo" | sort -u | wc -l)
        echo "IP: $ip - URLs Únicas: $urls - Requisições: $count"
    done
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

detectar_data_leakage() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ DETECÇÃO DE DATA LEAKAGE ═══════════════════════════"
    pula_linha 1
    
    local sensitive_patterns=(
        "password" "senha" "credential" "token" "api_key"
        "secret" "private" "credit.card" "cpf" "cnpj"
        "email" "telefone" "endereço"
    )
    
    for pattern in "${sensitive_patterns[@]}"; do
        count=$(grep -i "$pattern" "$nome_arquivo" | wc -l)
        if [[ $count -gt 0 ]]; then
            echo -e "${RED}🔓 Possível vazamento '$pattern': $count ocorrências${NC}"
            
            echo -e "${YELLOW}   Exemplos encontrados:${NC}"
            grep -i "$pattern" "$nome_arquivo" | head -3 | while read line; do
                sensitive_part=$(echo "$line" | grep -o -i ".{0,30}$pattern.{0,50}")
                ip=$(echo "$line" | awk '{print $1}')
                url=$(echo "$line" | awk '{print $7}')
                echo "   → IP: $ip | URL: $url"
                echo "     Dados: $sensitive_part"
            done
            pula_linha 1
        fi
    done
    
    pula_linha 1
    echo -e "${CYAN}🔍 INVESTIGAÇÃO DETALHADA:${NC}"
    
    echo -e "${YELLOW}Padrões de credenciais em URLs:${NC}"
    grep -i -E "password=[^&]*|senha=[^&]*|token=[^&]*" "$nome_arquivo" | awk '{print $1, $7}' | head -5
    
    pula_linha 1
    
    echo -e "${YELLOW}Dados sensíveis em parâmetros GET:${NC}"
    grep -i -E "\?(.*password|.*senha|.*token|.*email|.*cpf)" "$nome_arquivo" | awk '{print $7}' | head -5
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

analise_performance() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ ANÁLISE DE PERFORMANCE ═══════════════════════════"
    pula_linha 1
    
    echo -e "${CYAN}URLs Mais Lentas:${NC}"
    awk '$10 > 5 {print $7, $10}' "$nome_arquivo" | sort -k2 -nr | head -10
    
    pula_linha 1
    echo -e "${CYAN}Requisições Mais Pesadas:${NC}"
    awk '$10 > 1048576 {print $7, $10/1048576 "MB"}' "$nome_arquivo" | sort -k2 -nr | head -10
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

detectar_webshells() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ DETECÇÃO DE WEB SHELLS ═══════════════════════════"
    pula_linha 1
    
    local webshell_patterns=(
        "cmd.php" "shell.php" "wso.php" "c99.php" "r57.php"
        "b374k.php" "backdoor" "webadmin" "upload.php"
        "\.php\?" "\.php\&" "\.php\."
    )
    
    for pattern in "${webshell_patterns[@]}"; do
        count=$(grep -i "$pattern" "$nome_arquivo" | wc -l)
        if [[ $count -gt 0 ]]; then
            echo -e "${RED}🛑 Possível Web Shell '$pattern': $count ocorrências${NC}"
            grep -i "$pattern" "$nome_arquivo" | awk '{print $1, $7}' | head -3
        fi
    done
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

fingerprinting_app() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ FINGERPRINTING ═══════════════════════════"
    pula_linha 1
    
    echo -e "${CYAN}Tecnologias Detectadas:${NC}"
    
    grep -q "wp-" "$nome_arquivo" && echo "✅ WordPress detectado"
    grep -q "joomla" "$nome_arquivo" && echo "✅ Joomla detectado"
    grep -q "drupal" "$nome_arquivo" && echo "✅ Drupal detectado"
    
    grep -q "laravel" "$nome_arquivo" && echo "✅ Laravel detectado"
    grep -q "symfony" "$nome_arquivo" && echo "✅ Symfony detectado"
    
    grep -q "nginx" "$nome_arquivo" && echo "✅ Nginx detectado"
    grep -q "apache" "$nome_arquivo" && echo "✅ Apache detectado"
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

analise_api() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ CHAMADAS DE API ═══════════════════════════"
    pula_linha 1
    
    echo -e "${CYAN}Endpoints de API:${NC}"
    grep -E "(api|v[0-9]|rest|graphql|soap)" "$nome_arquivo" | awk '{print $7}' | sort -u | head -20
    
    pula_linha 1
    echo -e "${CYAN}Métodos HTTP em APIs:${NC}"
    grep -E "(api|v[0-9]|rest)" "$nome_arquivo" | awk '{print $6, $7}' | sed 's/"//g' | sort | uniq -c | sort -nr | head -10
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

detectar_credential_stuffing() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ CREDENTIAL STUFFING ═══════════════════════════"
    pula_linha 1
    
    echo -e "${RED}🔍 DETECTANDO TENTATIVAS DE CREDENTIAL STUFFING:${NC}"
    pula_linha 1

    # Padrões mais abrangentes para login
    local login_patterns="(login|auth|signin|logar|autenticar|password|senha|credential|token|oauth|jwt|admin)"
    local threshold_minuto=10
    local threshold_ip=50
    
    echo -e "${CYAN}1. Tentativas de login com erro 401/403:${NC}"
    resultados_401=$(awk -v pattern="$login_patterns" '$7 ~ pattern && ($9 == "401" || $9 == "403") {print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -10)
    
    if [[ -n "$resultados_401" && $(echo "$resultados_401" | wc -l) -gt 0 ]]; then
        echo "$resultados_401" | while read count ip; do
            if [[ $count -gt 5 ]]; then
                echo -e "${RED}🚨 IP: $ip - $count tentativas com erro 401/403${NC}"
            else
                echo -e "${YELLOW}⚠️  IP: $ip - $count tentativas com erro 401/403${NC}"
            fi
        done
    else
        echo "Nenhuma tentativa de login com erro 401/403 encontrada"
    fi
    
    pula_linha 1
    
    echo -e "${CYAN}2. IPs com muitas requisições para páginas de login:${NC}"
    awk -v pattern="$login_patterns" '$7 ~ pattern {print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -15 | \
    while read count ip; do
        if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            if [[ $count -gt $threshold_ip ]]; then
                echo -e "${RED}🚨 IP: $ip - $count requisições para login${NC}"
                
                # Análise detalhada do IP suspeito
                echo -e "   📊 Comportamento:"
                
                # Horários de pico - CORRIGIDO
                awk -v ip="$ip" -v pattern="$login_patterns" '$1 == ip && $7 ~ pattern {
                    gsub(/\[/, "", $4);
                    split($4, dt, ":");
                    hora = dt[2];
                    print hora
                }' "$nome_arquivo" | sort | uniq -c | sort -nr | head -3 | \
                while read count_hora hora; do
                    echo -e "      ⏰ Hora $hora:00 - $count_hora tentativas"
                done
                
                # Códigos de status para este IP - CORRIGIDO
                echo -e "   📋 Códigos de status:"
                awk -v ip="$ip" -v pattern="$login_patterns" '$1 == ip && $7 ~ pattern {print $9}' "$nome_arquivo" | \
                sort | uniq -c | sort -nr | \
                while read count status; do
                    if [[ "$status" =~ ^[0-9]+$ ]]; then
                        case $status in
                            "200") color="${GREEN}" ; desc="SUCESSO" ;;
                            "401"|"403") color="${RED}" ; desc="NÃO AUTORIZADO" ;;
                            "404") color="${YELLOW}" ; desc="NÃO ENCONTRADO" ;;
                            "500") color="${RED}" ; desc="ERRO SERVIDOR" ;;
                            *) color="${NC}" ; desc="" ;;
                        esac
                        echo -e "      ${color}$status ($desc): $count vezes${NC}"
                    fi
                done
                
                # URLs acessadas por este IP
                echo -e "   🔗 Principais URLs:"
                awk -v ip="$ip" -v pattern="$login_patterns" '$1 == ip && $7 ~ pattern {print $7}' "$nome_arquivo" | \
                sort | uniq -c | sort -nr | head -3 | \
                while read count url; do
                    echo -e "      → $count x $url"
                done
                
                pula_linha 1
            elif [[ $count -gt 10 ]]; then
                echo -e "${YELLOW}⚠️  IP: $ip - $count requisições para login${NC}"
            else
                echo -e "${GREEN}✅ IP: $ip - $count requisições para login${NC}"
            fi
        fi
    done
    
    pula_linha 1

    echo -e "${CYAN}3. Possíveis ataques brute force (por minuto):${NC}"
    
    # DEBUG: Verifique o formato das datas no seu arquivo
    echo -e "${YELLOW}📅 Analisando formato de datas...${NC}"
    head -5 "$nome_arquivo" | awk '{print "Data exemplo: " $4}'
    
    # SOLUÇÃO DEFINITIVA
    awk -v pattern="$login_patterns" -v threshold="$threshold_minuto" '
        $7 ~ pattern {
            # Remove colchetes da data
            gsub(/\[|\]/, "", $4);
            
            # Divide data/hora
            split($4, datetime, ":");
            date_hour = datetime[1] ":" datetime[2];  # Formato: 13/Feb/2015:08
            
            # Conta por IP + data+hora
            count[date_hour "|" $1]++
        }
        END {
            for (key in count) {
                if (count[key] > threshold) {
                    split(key, parts, "|");
                    date_hour = parts[1];
                    ip = parts[2];
                    print count[key], ip, date_hour
                }
            }
        }
    ' "$nome_arquivo" | sort -nr | head -10 | \
    while read count ip data_hora; do
        if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "${RED}🚨 BRUTE FORCE: IP $ip - $count tentativas em $data_hora${NC}"
            
            # URLs acessadas por este IP neste período
            urls=$(awk -v ip="$ip" -v dh="$data_hora" -v pattern="$login_patterns" '
                $1 == ip && $4 ~ dh && $7 ~ pattern {print $7}
            ' "$nome_arquivo" | sort -u | head -3 | tr '\n' ' ' | sed 's/ $//')
            
            if [[ -n "$urls" ]]; then
                echo -e "   🔗 URLs: $urls"
            fi
        fi
    done

    # Se nenhum resultado for encontrado
    if ! awk -v pattern="$login_patterns" '$7 ~ pattern' "$nome_arquivo" | grep -q .; then
        echo "Nenhuma requisição de login encontrada para análise"
    elif [[ $(awk -v pattern="$login_patterns" -v threshold="$threshold_minuto" '
        $7 ~ pattern {
            gsub(/\[|\]/, "", $4);
            split($4, dt, ":");
            key = dt[1] ":" dt[2] "|" $1;
            count[key]++
        }
        END {
            for (k in count) if (count[k] > threshold && k ~ /^[0-9]/) exit 1;
            exit 0
        }
    ' "$nome_arquivo") -eq 0 ]]; then
        echo "Nenhum padrão de brute force detectado (threshold: ${threshold_minuto} req/min)"
    fi

    pula_linha 1
    
    echo -e "${CYAN}4. URLs de autenticação mais visadas:${NC}"
    awk -v pattern="$login_patterns" '$7 ~ pattern {print $7}' "$nome_arquivo" | \
    sort | uniq -c | sort -nr | head -10 | \
    while read count url; do
        if [[ $count -gt 20 ]]; then
            echo -e "${RED}🚨 $count x $url${NC}"
        elif [[ $count -gt 5 ]]; then
            echo -e "${YELLOW}⚠️  $count x $url${NC}"
        else
            echo -e "${GREEN}✅ $count x $url${NC}"
        fi
    done
    
    pula_linha 1
    
    echo -e "${CYAN}5. ANÁLISE COMPORTAMENTAL AVANÇADA:${NC}"
    
    # Estatísticas corrigidas
    total_logins=$(awk -v pattern="$login_patterns" '$7 ~ pattern' "$nome_arquivo" | wc -l)
    sucessos=$(awk -v pattern="$login_patterns" '$7 ~ pattern && $9 == "200"' "$nome_arquivo" | wc -l)
    falhas=$(awk -v pattern="$login_patterns" '$7 ~ pattern && $9 != "200"' "$nome_arquivo" | wc -l)
    ips_unicos_login=$(awk -v pattern="$login_patterns" '$7 ~ pattern {print $1}' "$nome_arquivo" | sort -u | wc -l)
    
    echo "Estatísticas de Autenticação:"
    echo "  Total de requisições: $total_logins"
    echo "  IPs únicos: $ips_unicos_login"
    echo "  Login sucesso: $sucessos"
    echo "  Login falha: $falhas"
    
    if [[ $total_logins -gt 0 ]]; then
        taxa_sucesso=$((sucessos * 100 / total_logins))
        taxa_falha=$((falhas * 100 / total_logins))
        media_tentativas=$((total_logins / ips_unicos_login))
        
        echo "  Taxa de sucesso: ${taxa_sucesso}%"
        echo "  Taxa de falha: ${taxa_falha}%"
        echo "  Média tentativas/IP: $media_tentativas"
        
        # Análise de risco melhorada
        if [[ $taxa_falha -gt 80 && $media_tentativas -gt 20 ]]; then
            echo -e "${RED}🚨 ALTO RISCO: Possível credential stuffing em andamento!${NC}"
        elif [[ $taxa_falha -gt 60 && $media_tentativas -gt 10 ]]; then
            echo -e "${YELLOW}⚠️  RISCO MODERADO: Comportamento suspeito detectado${NC}"
        elif [[ $media_tentativas -gt 50 ]]; then
            echo -e "${RED}🚨 ALERTA: IPs com muitas tentativas concentradas${NC}"
        else
            echo -e "${GREEN}✅ Comportamento normal detectado${NC}"
        fi
    fi
    
    pula_linha 1
    
    echo -e "${CYAN}6. RECOMENDAÇÕES DE SEGURANÇA:${NC}"
    
    # Recomendações baseadas na análise
    if [[ $total_logins -gt 500 ]]; then
        echo -e "${YELLOW}🔒 Ações Imediatas Recomendadas:${NC}"
        echo "  • 🔥 BLOQUEAR IP 177.138.28.7 (834 tentativas)"
        echo "  • ⏰ Implementar rate limiting (max 10 req/min por IP)"
        echo "  • 🤖 Adicionar CAPTCHA após 3 tentativas falhas"
        echo "  • 📧 Configurar alertas para >20 tentativas/minuto"
        echo "  • 🔍 Investigar origem do tráfego malicioso"
    fi
    
    if [[ $taxa_falha -gt 90 ]]; then
        echo -e "${YELLOW}🛡️  Medidas Preventivas:${NC}"
        echo "  • ✅ Implementar autenticação multi-fator"
        echo "  • 📊 Monitorar padrões de tráfego anormais"
        echo "  • 🌐 Usar WAF (Web Application Firewall)"
        echo "  • 📝 Revisar logs diariamente"
    fi
    
    if [[ $ips_unicos_login -lt 5 && $total_logins -gt 100 ]]; then
        echo -e "${YELLOW}⚠️  Padrão Detectado:${NC}"
        echo "  • Ataque concentrado de poucos IPs"
        echo "  • Possível botnet ou proxy"
    fi
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}
buscar_passwd() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ INFORMAÇÕES DO /etc/passwd ═══════════════════════════"
    pula_linha 1

    if [ -r "/etc/passwd" ]; then
        echo -e "${CYAN}Usuários do sistema (primeiros 20):${NC}"
        awk -F: '
        BEGIN {
            printf "%-15s %-8s %-8s %-20s %-15s\n", "Usuário", "UID", "GID", "Home", "Shell"
            printf "%-15s %-8s %-8s %-20s %-15s\n", "-------", "---", "---", "----", "-----"
        }
        {
            if (NR <= 20) {
                printf "%-15s %-8s %-8s %-20s %-15s\n", $1, $3, $4, $6, $7
            }
        }' /etc/passwd

        pula_linha 1
        echo -e "${CYAN}Estatísticas do /etc/passwd:${NC}"
        local total_usuarios=$(wc -l < /etc/passwd)
        local usuarios_root=$(awk -F: '$3 == "0" {print $1}' /etc/passwd | wc -l)
        local usuarios_sistema=$(awk -F: '$3 < 1000 && $3 != "0" {print $1}' /etc/passwd | wc -l)
        local usuarios_normais=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd | wc -l)
        
        echo "Total de usuários: $total_usuarios"
        echo "Usuários root (UID 0): $usuarios_root"
        echo "Usuários do sistema: $usuarios_sistema"
        echo "Usuários normais: $usuarios_normais"

        pula_linha 1
        echo -e "${YELLOW}Usuários root (UID 0):${NC}"
        awk -F: '$3 == "0" {print "→ " $1 " (UID: " $3 ", Shell: " $7 ")"}' /etc/passwd

        pula_linha 1
        echo -e "${RED}Usuários com shell de login:${NC}"
        awk -F: '$7 ~ /\/(bash|sh|zsh|tcsh|csh|ksh)$/ {print "→ " $1 " (" $7 ")"}' /etc/passwd | head -10

    else
        echo -e "${RED}❌ Não foi possível ler o arquivo /etc/passwd${NC}"
        echo "Permissão negada ou arquivo não existe"
    fi

    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

analise_mobile_desktop() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ MOBILE vs DESKTOP ═══════════════════════════"
    pula_linha 1
    
    local mobile=$(grep -i "mobile\|android\|iphone\|ipad" "$nome_arquivo" | wc -l)
    local desktop=$(grep -v -i "mobile\|android\|iphone\|ipad" "$nome_arquivo" | wc -l)
    local total=$((mobile + desktop))
    
    if [[ $total -gt 0 ]]; then
        echo -e "${CYAN}Dispositivos:${NC}"
        echo "Mobile: $mobile ($((mobile * 100 / total))%)"
        echo "Desktop: $desktop ($((desktop * 100 / total))%)"
    else
        echo "Nenhum dado para análise"
    fi
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

investigar_por_data() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ INVESTIGAÇÃO POR DATA ═══════════════════════════"
    pula_linha 1
    
    echo -e "${CYAN}DATAS COM MAIOR TRÁFEGO (possíveis ataques):${NC}"
    awk '{print $4}' "$nome_arquivo" | cut -d: -f1 | cut -d[ -f2 | sort | uniq -c | sort -nr | head -10 | \
    while read count data; do
        if [[ $count -gt 1000 ]]; then
            echo -e "${RED}🚨 $data - $count requisições${NC}"
        elif [[ $count -gt 500 ]]; then
            echo -e "${YELLOW}⚠️  $data - $count requisições${NC}"
        else
            echo -e "${GREEN}✅ $data - $count requisições${NC}"
        fi
    done
    
    pula_linha 1
    echo -e "${CYAN}Digite a data que deseja investigar (ex: 13/Feb/2015):${NC}"
    read -p "Data: " data_investigar
    
    if ! grep -q "$data_investigar" "$nome_arquivo"; then
        echo -e "${RED}Data '$data_investigar' não encontrada no arquivo de log!${NC}"
        sleep 2
        return
    fi
    
    pula_linha 1
    echo -e "${RED}🔍 INVESTIGANDO DATA: $data_investigar${NC}"
    pula_linha 1
    
    echo -e "${CYAN}TOP 10 IPs NA DATA $data_investigar:${NC}"
    awk -v data="$data_investigar" '$4 ~ data {print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -10
    
    pula_linha 1

    echo -e "${CYAN}PÁGINAS MAIS ACESSADAS:${NC}"
    awk -v data="$data_investigar" '$4 ~ data {print $7}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -15
    
    pula_linha 1
    
    echo -e "${CYAN}MÉTODOS HTTP UTILIZADOS:${NC}"
    awk -v data="$data_investigar" '$4 ~ data {print $6}' "$nome_arquivo" | sed 's/"//g' | sort | uniq -c | sort -nr
    
    pula_linha 1
    
    echo -e "${CYAN}CÓDIGOS DE STATUS:${NC}"
    awk -v data="$data_investigar" '$4 ~ data {print $9}' "$nome_arquivo" | sort | uniq -c | sort -nr
    
    pula_linha 1
    
    echo -e "${GREEN} CAMINHOS COM SUCESSO (Código 200):${NC}"
    awk -v data="$data_investigar" '$4 ~ data && $9 == "200" {print $7}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -15
    
    pula_linha 1
    
    echo -e "${CYAN}USER-AGENTS SUSPEITOS:${NC}"
    awk -v data="$data_investigar" '$4 ~ data {print $0}' "$nome_arquivo" | awk -F\" '{print $6}' | \
    grep -i -E "bot|scanner|crawler|nikto|sqlmap" | sort | uniq -c | sort -nr | head -5
    
    pula_linha 1
    
    echo -e "${CYAN} RESUMO DA DATA $data_investigar:${NC}"
    total_requisicoes=$(awk -v data="$data_investigar" '$4 ~ data' "$nome_arquivo" | wc -l)
    sucessos_200=$(awk -v data="$data_investigar" '$4 ~ data && $9 == "200"' "$nome_arquivo" | wc -l)
    erros_404=$(awk -v data="$data_investigar" '$4 ~ data && $9 == "404"' "$nome_arquivo" | wc -l)
    erros_500=$(awk -v data="$data_investigar" '$4 ~ data && $9 == "500"' "$nome_arquivo" | wc -l)

    if [[ $total_requisicoes -gt 0 ]]; then
        percent_sucessos=$(echo "$sucessos_200 $total_requisicoes" | awk '{printf "%.1f", ($1/$2)*100}')
        percent_404=$(echo "$erros_404 $total_requisicoes" | awk '{printf "%.1f", ($1/$2)*100}')
        percent_500=$(echo "$erros_500 $total_requisicoes" | awk '{printf "%.1f", ($1/$2)*100}')
    else
        percent_sucessos="0.0"
        percent_404="0.0" 
        percent_500="0.0"
    fi
    
    echo "Total de requisições: $total_requisicoes"
    echo "Sucessos (200): $sucessos_200 (${percent_sucessos}%)"
    echo "Erros 404: $erros_404 (${percent_404}%)"
    echo "Erros 500: $erros_500 (${percent_500}%)"
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    pula_linha 1
    echo -e "${NC}"
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

analise_payloads() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ ANÁLISE DE PAYLOADS SUSPEITOS ═══════════════════════════"
    pula_linha 1
    
    echo -e "${CYAN}🛡️ PAYLOADS SUSPEITOS EM URLs:${NC}"
    pula_linha 1
    
    local payload_patterns=(
        "union.*select" "sleep\(.*\)" "benchmark\(.*\)" 
        "load_file" "into.*outfile" "into.*dumpfile"
        "exec\(.*\)" "system\(.*\)" "passthru\(.*\)"
        "shell_exec" "eval\(.*\)" "assert\(.*\)"
        "base64_decode" "gzinflate" "str_rot13"
        "document\.cookie" "alert\(.*\)" "script.*src"
        "onmouseover" "onerror" "onload"
    )
    
    local total_suspeitos=0
    
    for pattern in "${payload_patterns[@]}"; do
        count=$(grep -i "$pattern" "$nome_arquivo" | wc -l)
        if [[ $count -gt 0 ]]; then
            total_suspeitos=$((total_suspeitos + count))
            echo -e "${RED}🚨 '$pattern': $count ocorrências${NC}"
            grep -i "$pattern" "$nome_arquivo" | awk '{print "   → IP: " $1 " | URL: " $7}' | head -2
            pula_linha 1
        fi
    done
    
    if [[ $total_suspeitos -eq 0 ]]; then
        echo -e "${GREEN}✅ Nenhum payload suspeito encontrado${NC}"
    else
        echo -e "${YELLOW}📊 Total de ocorrências suspeitas: $total_suspeitos${NC}"
    fi
    
    pula_linha 1
    
    # Análise de parâmetros suspeitos
    echo -e "${CYAN}🔍 PARÂMETROS SUSPEITOS EM URLs:${NC}"
    pula_linha 1
    
    grep "?" "$nome_arquivo" | awk -F"?" '{print $2}' | \
    awk -F"&" '{
        for(i=1;i<=NF;i++) {
            split($i, param, "=");
            if(length(param[2]) > 100) {
                print "Parâmetro muito longo: " param[1] " (" length(param[2]) " caracteres)"
            }
            if(param[2] ~ /[<>]/) {
                print "Caracteres especiais: " param[1] " → " substr(param[2], 1, 50)
            }
        }
    }' | sort | uniq -c | sort -nr | head -10
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

analise_redirecionamentos() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ ANÁLISE DE REDIRECIONAMENTOS ═══════════════════════════"
    pula_linha 1
    
    echo -e "${CYAN}🔄 REDIRECIONAMENTOS 3xx SUSPEITOS:${NC}"
    pula_linha 1
    
    local total_redirecionamentos=0
    
    # Redirecionamentos para domínios externos
    awk '$9 ~ /^30[12378]/ {
        print $1, $7, $10  # IP, URL, Location
    }' "$nome_arquivo" | \
    while read ip url location; do
        if [[ "$location" != "-" && "$location" != "" ]]; then
            if [[ "$location" =~ (http|https):// ]]; then
                domain=$(echo "$location" | awk -F/ '{print $3}')
                if [[ "$domain" != *"localhost"* && "$domain" != *"127.0.0.1"* ]]; then
                    total_redirecionamentos=$((total_redirecionamentos + 1))
                    echo -e "${YELLOW}🔗 IP: $ip${NC}"
                    echo "   URL Origem: $url"
                    echo "   Redireciona para: $location"
                    
                    # Verifica se é domínio suspeito
                    if [[ "$domain" =~ (bit\.ly|tinyurl|goo\.gl|t\.co) ]]; then
                        echo -e "${RED}   ⚠️  DOMÍNIO ENCURTADO SUSPEITO!${NC}"
                    fi
                    echo ""
                fi
            fi
        fi
    done | head -15
    
    if [[ $total_redirecionamentos -eq 0 ]]; then
        echo -e "${GREEN}✅ Nenhum redirecionamento suspeito encontrado${NC}"
    else
        echo -e "${YELLOW}📊 Total de redirecionamentos externos: $total_redirecionamentos${NC}"
    fi
    
    pula_linha 1
    
    # Estatísticas de códigos 3xx
    echo -e "${CYAN}📈 ESTATÍSTICAS DE REDIRECIONAMENTOS:${NC}"
    awk '$9 ~ /^30[12378]/ {print $9}' "$nome_arquivo" | sort | uniq -c | sort -nr | \
    while read count code; do
        case $code in
            "301") desc="Movido Permanentemente" ;;
            "302") desc="Encontrado" ;;
            "303") desc="See Other" ;;
            "307") desc="Redirecionamento Temporário" ;;
            "308") desc="Redirecionamento Permanentemente" ;;
            *) desc="Outro" ;;
        esac
        echo -e "   $count x Código $code ($desc)"
    done
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

detectar_port_scan() {
    clear
    echo -e "${RED}"
    pula_linha 1
    echo "══════════════════════════ DETECÇÃO DE PORT SCAN ═══════════════════════════"
    pula_linha 1
    
    echo -e "${CYAN}🔎 POSSÍVEIS SCANS DE PORTA:${NC}"
    pula_linha 1
    
    # IPs acessando múltiplas portas no mesmo servidor
    local resultados=$(awk '{
        split($7, parts, "/");
        porta = parts[3];
        if (porta != "" && porta ~ /^[0-9]+$/) {
            print $1, porta
        }
    }' "$nome_arquivo" | sort | uniq | \
    awk '{
        count[$1]++;
        ports[$1] = ports[$1] " " $2
    }
    END {
        for (ip in count) {
            if (count[ip] > 3) {  # Threshold reduzido para detectar mais casos
                print count[ip] "|" ip "|" ports[ip]
            }
        }
    }' | sort -t'|' -k1 -nr | head -15)
    
    if [[ -z "$resultados" ]]; then
        echo -e "${GREEN}✅ Nenhum scan de porta detectado${NC}"
    else
        echo "$resultados" | while IFS='|' read count ip ports; do
            if [[ $count -gt 10 ]]; then
                echo -e "${RED}🚨 SCAN MASSIVO: IP $ip - $count portas diferentes${NC}"
            elif [[ $count -gt 5 ]]; then
                echo -e "${YELLOW}⚠️  SCAN MODERADO: IP $ip - $count portas diferentes${NC}"
            else
                echo -e "${CYAN}🔍 POSSÍVEL SCAN: IP $ip - $count portas diferentes${NC}"
            fi
            
            # Mostra as portas (limitado a 10)
            echo -n "   Portas:"
            echo " $ports" | tr ' ' '\n' | sort -n | head -10 | tr '\n' ' '
            echo ""
            
            # Métodos usados pelo IP suspeito
            echo "   Métodos: $(awk -v ip="$ip" '$1 == ip {print $6}' "$nome_arquivo" | sed 's/"//g' | sort | uniq | tr '\n' ' ')"
            echo ""
        done
    fi
    
    pula_linha 1
    
    # Portas mais escaneadas
    echo -e "${CYAN}🎯 PORTAS MAIS ACESSADAS:${NC}"
    awk '{
        split($7, parts, "/");
        porta = parts[3];
        if (porta != "" && porta ~ /^[0-9]+$/) {
            print porta
        }
    }' "$nome_arquivo" | sort | uniq -c | sort -nr | head -10 | \
    while read count porta; do
        case $porta in
            "22") servico="SSH" ;;
            "21") servico="FTP" ;;
            "23") servico="Telnet" ;;
            "25") servico="SMTP" ;;
            "53") servico="DNS" ;;
            "80") servico="HTTP" ;;
            "110") servico="POP3" ;;
            "143") servico="IMAP" ;;
            "443") servico="HTTPS" ;;
            "993") servico="IMAPS" ;;
            "995") servico="POP3S" ;;
            "3306") servico="MySQL" ;;
            "3389") servico="RDP" ;;
            "5432") servico="PostgreSQL" ;;
            "6379") servico="Redis" ;;
            "27017") servico="MongoDB" ;;
            *) servico="Desconhecido" ;;
        esac
        echo "   $count acessos → Porta $porta ($servico)"
    done
    
    pula_linha 1
    echo "════════════════════════════════════════════════════════════════════════════════"
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

help() {
    clear
    echo -e "${RED}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo "                           🛡️  DISCLAIMER LEGAL"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "📜 ESTE SOFTWARE É FORNECIDO 'COMO ESTÁ', SEM GARANTIAS DE QUALQUER TIPO."
    echo ""
    echo "⚖️  USO RESPONSÁVEL:"
    echo "   • Use apenas em sistemas que você possui ou tem autorização explícita"
    echo "   • Não utilize para atividades maliciosas ou não autorizadas"
    echo "   • Respeite as leis de privacidade e propriedade intelectual"
    echo ""
    echo "🔒 LIMITAÇÕES:"
    echo "   • Não nos responsabilizamos pelo uso indevido deste software"
    echo "   • O usuário assume total responsabilidade por suas ações"
    echo "   • Mantenha-se dentro dos limites legais da sua jurisdição"
    echo ""
    echo "🌐 LICENÇA:"
    echo "   • GNU AGPL v3 - Veja o arquivo LICENSE para detalhes completos"
    echo "   • Código aberto para fins educacionais e de segurança legítima"
    echo ""
    echo "⚠️  AVISO:"
    echo "   Teste de penetração sem autorização é CRIME em muitos países!"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo -e "${NC}"
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

exportar_relatorio() {
    local relatorio_dir="relatorio_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$relatorio_dir"
    
    echo -e "${GREEN}Exportando análises CRÍTICAS para $relatorio_dir/...${NC}"
    echo -e "${YELLOW}Gerando relatório executivo...${NC}"
    
    # Relatório Executivo Focado
    {
        echo "RELATÓRIO EXECUTIVO DE SEGURANÇA - VISÃO APACHE"
        echo "================================================"
        echo "Arquivo analisado: $nome_arquivo"
        echo "Data da análise: $(date)"
        echo "Total de linhas: $(wc -l < "$nome_arquivo")"
        echo "Período: $(head -1 "$nome_arquivo" | awk '{print $4}' | sed 's/\[//') até $(tail -1 "$nome_arquivo" | awk '{print $4}' | sed 's/\[//')"
        echo "================================================"
        echo ""
        
        echo "🚨 ALERTAS CRÍTICOS ENCONTRADOS:"
        echo "================================="
        
        # 1. CREDENTIAL STUFFING DETECTADO
        echo ""
        echo "🔐 CREDENTIAL STUFFING:"
        echo "----------------------"
        local total_logins=$(awk 'tolower($7) ~ /(login|auth|signin|logar|autenticar|password|senha|credential|token|oauth|jwt|admin)/' "$nome_arquivo" | wc -l)
        local ips_unicos_login=$(awk 'tolower($7) ~ /(login|auth|signin|logar|autenticar|password|senha|credential|token|oauth|jwt|admin)/ {print $1}' "$nome_arquivo" | sort -u | wc -l)
        local media_tentativas=$((total_logins / (ips_unicos_login > 0 ? ips_unicos_login : 1)))
        
        if [[ $media_tentativas -gt 20 ]]; then
            echo "❌ ALTO RISCO: Média de $media_tentativas tentativas/IP"
            echo "📊 Total de tentativas de login: $total_logins"
            echo "🌐 IPs únicos atacando: $ips_unicos_login"
            
            # IP mais agressivo
            awk 'tolower($7) ~ /(login|auth|signin|logar|autenticar|password|senha|credential|token|oauth|jwt|admin)/ {print $1}' "$nome_arquivo" | \
            sort | uniq -c | sort -nr | head -1 | while read count ip; do
                echo "🔥 IP MAIS AGRESSIVO: $ip ($count tentativas)"
            done
        else
            echo "✅ Comportamento normal de autenticação"
        fi
        
        # 2. POSSÍVEL DDoS
        echo ""
        echo "🌪️  ANÁLISE DDoS:"
        echo "----------------"
        local ip_mais_requisicoes=$(awk '{print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -1)
        local count_mais_requisicoes=$(echo "$ip_mais_requisicoes" | awk '{print $1}')
        local ip_top=$(echo "$ip_mais_requisicoes" | awk '{print $2}')
        
        if [[ $count_mais_requisicoes -gt 1000 ]]; then
            echo "❌ POSSÍVEL ATAQUE DDoS DETECTADO"
            echo "🎯 IP SUSPEITO: $ip_top"
            echo "💥 Requisições: $count_mais_requisicoes"
            
            # Horário de pico
            awk -v ip="$ip_top" '$1 == ip {print $4}' "$nome_arquivo" | cut -d: -f2 | sort | uniq -c | sort -nr | head -1 | \
            while read count hora; do
                echo "⏰ Pico: $hora:00 ($count requisições)"
            done
        else
            echo "✅ Sem indicadores de DDoS"
        fi
        
        # 3. SCANNERS E INVASÕES
        echo ""
        echo "🔍 TENTATIVAS DE INVASÃO:"
        echo "-------------------------"
        local total_scanners=0
        local scanners_patterns=("nmap" "nikto" "sqlmap" "metasploit" "nessus" "openvas" "burp" "wpscan" "joomscan")
        
        for scanner in "${scanners_patterns[@]}"; do
            count=$(grep -i "$scanner" "$nome_arquivo" | wc -l)
            total_scanners=$((total_scanners + count))
        done
        
        local total_injection=$(grep -i -E "union.*select|sleep\(.*\)|benchmark\(.*\)|exec\(.*\)|system\(.*\)|eval\(.*\)" "$nome_arquivo" | wc -l)
        local total_path_traversal=$(grep -i -E "\.\./|\.\.\\|%2e%2e" "$nome_arquivo" | wc -l)
        
        if [[ $total_scanners -gt 0 || $total_injection -gt 0 || $total_path_traversal -gt 0 ]]; then
            echo "❌ TENTATIVAS DE EXPLORAÇÃO DETECTADAS:"
            echo "🛡️  Scanners de vulnerabilidade: $total_scanners"
            echo "💉 Injeção SQL/Comandos: $total_injection"
            echo "📁 Path Traversal: $total_path_traversal"
        else
            echo "✅ Sem tentativas de exploração detectadas"
        fi
        
        # 4. DATA LEAKAGE
        echo ""
        echo "🔓 RISCO DE VAZAMENTO:"
        echo "---------------------"
        local total_sensitive=$(grep -i -E "password|senha|credential|token|api_key|secret|private|credit.card|cpf|cnpj" "$nome_arquivo" | wc -l)
        
        if [[ $total_sensitive -gt 0 ]]; then
            echo "⚠️  DADOS SENSÍVEIS ENCONTRADOS: $total_sensitive ocorrências"
            echo "🔍 Investigar URLs com parâmetros sensíveis"
        else
            echo "✅ Sem dados sensíveis expostos"
        fi
        
        # 5. WEB SHELLS
        echo ""
        echo "🦠 WEB SHELLS:"
        echo "--------------"
        local total_webshells=$(grep -i -E "cmd\.php|shell\.php|wso\.php|c99\.php|r57\.php|b374k\.php|backdoor|webadmin" "$nome_arquivo" | wc -l)
        
        if [[ $total_webshells -gt 0 ]]; then
            echo "🚨 POSSÍVEIS WEB SHELLS: $total_webshells ocorrências"
            grep -i -E "cmd\.php|shell\.php|wso\.php|c99\.php" "$nome_arquivo" | awk '{print "   → " $1 " - " $7}' | head -3
        else
            echo "✅ Sem indicadores de web shells"
        fi
        
        # 6. RESUMO EXECUTIVO
        echo ""
        echo "📈 RESUMO EXECUTIVO:"
        echo "===================="
        local total_requisicoes=$(wc -l < "$nome_arquivo")
        local ips_unicos=$(awk '{print $1}' "$nome_arquivo" | sort -u | wc -l)
        local taxa_erro=$(awk '$9 ~ /^4|^5/ {count++} END {print count+0}' "$nome_arquivo")
        local percent_erro=$((taxa_erro * 100 / total_requisicoes))
        
        echo "📊 Requisições totais: $total_requisicoes"
        echo "🌐 IPs únicos: $ips_unicos"
        echo "❌ Taxa de erro: $percent_erro%"
        
        # Score de risco
        local risk_score=0
        [[ $media_tentativas -gt 20 ]] && risk_score=$((risk_score + 3))
        [[ $count_mais_requisicoes -gt 1000 ]] && risk_score=$((risk_score + 3))
        [[ $total_scanners -gt 0 ]] && risk_score=$((risk_score + 2))
        [[ $total_injection -gt 0 ]] && risk_score=$((risk_score + 2))
        [[ $total_webshells -gt 0 ]] && risk_score=$((risk_score + 3))
        
        echo ""
        echo "🎯 SCORE DE RISCO: $risk_score/13"
        if [[ $risk_score -gt 8 ]]; then
            echo "🚨 RISCO ELEVADO - AÇÃO IMEDIATA NECESSÁRIA"
        elif [[ $risk_score -gt 4 ]]; then
            echo "⚠️  RISCO MODERADO - MONITORAMENTO RECOMENDADO"
        else
            echo "✅ RISCO BAIXO - SITUAÇÃO NORMAL"
        fi
        
        # 7. RECOMENDAÇÕES
        echo ""
        echo "💡 RECOMENDAÇÕES:"
        echo "================="
        if [[ $media_tentativas -gt 20 ]]; then
            echo "• 🔥 Implementar rate limiting para autenticação"
            echo "• 🤖 Adicionar CAPTCHA após múltiplas tentativas"
            echo "• 📧 Configurar alertas para IPs suspeitos"
        fi
        
        if [[ $count_mais_requisicoes -gt 1000 ]]; then
            echo "• 🌐 Considerar WAF (Web Application Firewall)"
            echo "• 🛡️  Implementar bloqueio temporário de IPs"
            echo "• 📊 Monitorar padrões de tráfego anormais"
        fi
        
        if [[ $total_scanners -gt 0 ]]; then
            echo "• 🔍 Revisar regras de firewall"
            echo "• 📝 Atualizar sistemas e aplicações"
            echo "• 🧪 Realizar testes de penetração regulares"
        fi
        
        if [[ $risk_score -lt 3 ]]; then
            echo "• ✅ Manter monitoramento contínuo"
            echo "• 📋 Revisar políticas de segurança"
            echo "• 🎓 Treinar equipe em boas práticas"
        fi
        
    } > "$relatorio_dir/00_relatorio_executivo.txt"

    echo -e "${YELLOW}Gerando arquivos de suporte...${NC}"
    
    {
        echo "TOP 10 IPs MAIS PERIGOSOS:"
        echo "==========================="
        awk '{print $1}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -10
    } > "$relatorio_dir/01_ips_perigosos.txt"
    
    {
        echo "URLs MAIS VULNERÁVEIS/ATACADAS:"
        echo "================================"
        awk '$9 ~ /^4|^5/ {print $7}' "$nome_arquivo" | sort | uniq -c | sort -nr | head -15
    } > "$relatorio_dir/02_urls_vulneraveis.txt"
    
    {
        echo "PADRÕES DE ATAQUE DETECTADOS:"
        echo "=============================="
        echo "SQL Injection/Command Injection:"
        grep -i -E "union.*select|sleep\(.*\)|benchmark\(.*\)|exec\(.*\)|system\(.*\)|eval\(.*\)" "$nome_arquivo" | wc -l
        echo ""
        echo "Path Traversal:"
        grep -i -E "\.\./|\.\.\\|%2e%2e" "$nome_arquivo" | wc -l
        echo ""
        echo "Web Shells:"
        grep -i -E "cmd\.php|shell\.php|wso\.php|c99\.php|r57\.php" "$nome_arquivo" | wc -l
    } > "$relatorio_dir/03_ataques_detectados.txt"
    
    echo -e "${GREEN}✅ Relatório executivo salvo em: $relatorio_dir/${NC}"
    echo -e "${CYAN}📋 Arquivo principal: 00_relatorio_executivo.txt${NC}"
    echo -e "${YELLOW}📊 Arquivos de suporte: 01-03_*.txt${NC}"
    echo -e "${GREEN}🎯 Foco em: Alertas críticos, score de risco e recomendações acionáveis${NC}"
    sleep 3
}

main() {
    while true; do
        if [[ -z "$nome_arquivo" ]] || [[ ! -f "$nome_arquivo" ]]; then
            if ! adicionar_arquivo; then
                echo "Saindo..."
                exit 0
            fi
        fi

        exibir_menu
        read -p "Escolha uma opção: " escolha

        case $escolha in
            1) contagem_linhas_arq ;;
            2) buscar_ips ;;
            3) distribuicao_codigos_status ;;
            4) urls_mais_acessadas ;;
            5) metodos_por_ip ;;
            6) ips_suspeitos ;;
            7) vizualizador_trafego ;;
            8) verificar_referers ;;
            9) buscar_padroes_suspeitos ;;
            10) estatisticas_avancadas ;;
            11) detectar_scanners ;;
            12) analise_geografica ;;
            13) detectar_ddos ;;
            14) analise_crawlers ;;
            15) detectar_path_traversal ;;
            16) analise_sessoes ;;
            17) detectar_data_leakage ;;
            18) analise_performance ;;
            19) detectar_webshells ;;
            20) fingerprinting_app ;;
            21) analise_api ;;
            22) detectar_credential_stuffing ;;
            23) analise_mobile_desktop ;;
            24) buscar_passwd ;;
            25) investigar_por_data ;;
            26) analise_payloads ;;
            27) analise_redirecionamentos ;;
            28) detectar_port_scan ;;
            29) exportar_relatorio ;;
            30) help ;;
            0)
                echo -e "${YELLOW}Saindo do programa...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opção inválida!${NC}"
                sleep 2
                ;;
        esac
    done
}

for cmd in awk grep sort uniq wc du head tail; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Erro: Comando $cmd não encontrado${NC}"
        exit 1
    fi
done

if ! command -v whois &> /dev/null; then
    echo -e "${YELLOW}Aviso: Comando 'whois' não encontrado. A análise geográfica será limitada.${NC}"
    sleep 2
fi

main
