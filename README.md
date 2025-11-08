# 🛡️ Visão Apache - Analisador de Logs de Segurança

<p align="center">
  <img src="https://github.com/user-attachments/assets/b7724dac-b403-4332-b1ec-bb79cbfc6903" alt="Banner" width="80%">
</p>
## 📋 Sobre o Projeto
O **Visão Apache** é uma ferramenta avançada de análise de logs de servidores web escrita em **Bash**, projetada para detectar padrões suspeitos, tentativas de invasão e ameaças de segurança em arquivos de log do Apache.

## 🎯 Objetivo
Analisar arquivos de log de servidores web (Apache2) de maneira eficiente e interativa para identificar atividades maliciosas e padrões de ataque.

> 💡 Logs do sistema e de rede fornecem informações cruciais sobre o que aconteceu em um sistema. Mesmo que um atacante tente limpar suas pistas, algumas evidências sempre permanecem.

---

## 🚀 Instalação Rápida

### Pré-requisitos
```bash
# Sistemas baseados em Debian/Ubuntu
sudo apt update && sudo apt install bash awk grep coreutils

# Sistemas baseados em RHEL/CentOS
sudo yum install bash awk grep coreutils
```

### Instalação
```bash
# 1. Clone ou baixe o script
git clone <seu-repositorio>
# OU
wget https://raw.githubusercontent.com/seu-usuario/visao-apache/main/visao_apache.sh

# 2. Torne executável
chmod +x visao_apache.sh

# 3. Execute
./visao_apache.sh
```

---

## 📁 Como Usar

### Passo 1: Preparar o Arquivo de Log
```bash
# Coloque seu arquivo de log na mesma pasta do script
cp /var/log/apache2/access.log ./
# OU
mv seu_arquivo_de_log.log ./
```

### Passo 2: Executar o Script
```bash
./visao_apache.sh
```

### Passo 3: Carregar o Arquivo

<p align="center">
  <img src="https://github.com/user-attachments/assets/92ada7ce-5bc2-42b2-aa66-18496ff8deb1" alt="Menu" width="70%">
</p>

Dentro do programa:
1. Selecione a opção **1** para usar arquivo no diretório atual
2. Digite o nome do arquivo (Ex: `access.log`)
3. O sistema validará e carregará o arquivo

---

## 🎮 Menu de Funcionalidades

<p align="center">
  <img width="609" height="817" alt="image" src="https://github.com/user-attachments/assets/b2a10b04-81ca-4f85-9ef9-18d9534281c1" />
</p>


| Opção | Funcionalidade | Descrição |
|--------|----------------|------------|
| 1 | Informações do arquivo | Metadados e estatísticas básicas |
| 2 | Análise de IP's | IPs únicos e mais ativos |
| 3 | Códigos de status HTTP | Distribuição de respostas HTTP |
| 4 | URLs mais acessadas | Páginas mais visitadas |
| 5 | Métodos por IP | Combinações IP/Método HTTP |
| 6 | IPs suspeitos | IPs com +50 requisições |
| 7 | Análise de User-Agents | Navegadores vs Bots |
| 8 | Referências | Fontes de tráfego |
| 9 | Padrões suspeitos | Tentativas de invasão |
| 10 | Estatísticas avançadas | Métricas detalhadas |

---

## 🛡️ Detecção de Ameaças


| Opção | Funcionalidade | Detecta |
|--------|----------------|----------|
| 11 | Scanners | Nikto, SQLMap, Nmap, etc |
| 13 | DDoS | Padrões de ataque distribuído |
| 15 | Path Traversal | Tentativas de acesso a diretórios |
| 17 | Data Leakage | Vazamento de dados sensíveis |
| 19 | Web Shells | Backdoors e shells remotos |
| 22 | Credential Stuffing | Ataques de força bruta |
| 26 | Payloads suspeitos | SQLi, XSS, Command Injection |
| 28 | Port Scan | Varredura de portas |

---

## 📊 Análises Avançadas


| Opção | Funcionalidade |
|--------|----------------|
| 12 | Análise Geográfica |
| 14 | Crawlers Legítimos |
| 16 | Análise de Sessões |
| 18 | Análise de Performance |
| 20 | Fingerprinting |
| 21 | Análise API |
| 23 | Mobile vs Desktop |
| 24 | Informações do sistema |
| 25 | Investigação por data |
| 27 | Análise de redirecionamentos |

---

## 📤 Exportação de Relatórios

**Opção 29:** Exporta um relatório executivo completo com:
- ✅ Score de risco
- 🚨 Alertas críticos
- 💡 Recomendações acionáveis
- 📊 Métricas chave

---

## 🎯 Casos de Uso

### Para Administradores de Sistema
```bash
# Monitorar tentativas de invasão
./visao_apache.sh
# → Opção 9: Padrões suspeitos
# → Opção 11: Detecção de scanners
```

### Para Analistas de Segurança
```bash
# Investigar incidentes
./visao_apache.sh
# → Opção 22: Credential stuffing
# → Opção 17: Data leakage
# → Opção 25: Investigação por data
```

### Para Desenvolvedores
```bash
# Otimizar performance
./visao_apache.sh
# → Opção 18: Análise de performance
# → Opção 4: URLs mais acessadas
```

---

## 🔧 Funcionalidades Técnicas

### ⚡ Performance
- Processamento otimizado com AWK
- Cache inteligente para análises repetidas
- Interface responsiva e rápida

### 🎨 Interface
- Menu colorido e intuitivo
- Navegação por teclas
- Feedback visual claro
- Indicadores de progresso

### 📈 Análises
- 30+ tipos de análise diferentes
- Detecção de padrões complexos
- Correlação de eventos
- Scoring de risco automatizado

---

## 🛡️ Segurança e Legalidade

### ⚖️ Disclaimer
```bash
⚠️  AVISO: Teste de penetração sem autorização é CRIME em muitos países!
```

### 🎯 Uso Ético
- Use apenas em sistemas que você possui
- Obtenha autorização explícita
- Respeite leis de privacidade
- Reporte vulnerabilidades encontradas

---

## 🐛 Solução de Problemas

### Erros Comuns e Soluções
```bash
# Erro: "Arquivo não encontrado"
# Solução: Verifique se o arquivo está na pasta correta

# Erro: "Sem permissão de leitura"
# Solução: chmod +r arquivo.log

# Erro: "Comando não encontrado"
# Solução: Instale awk/grep/coreutils
```

### Dicas de Uso
```bash
# Para logs muito grandes:
split -l 100000 access.log access_chunk_
# Analise por partes

# Para análise contínua:
tail -f access.log | ./visao_apache.sh
```

---

## 📞 Suporte e Contribuições

**Desenvolvedor:** Luan Calazans  
**LinkedIn:** [luan-bsc](https://linkedin.com/in/luan-bsc)  
**Licença:** GNU AGPL v3

### 🤝 Como Contribuir
1. Faça um fork do projeto  
2. Crie uma branch para sua feature  
3. Commit suas mudanças  
4. Push para a branch  
5. Abra um Pull Request

---

## 📊 Exemplo de Saída

### Relatório Executivo
```text
🚨 ALERTAS CRÍTICOS ENCONTRADOS:
=================================
🔐 CREDENTIAL STUFFING:
❌ ALTO RISCO: Média de 278 tentativas/IP
📊 Total de tentativas de login: 1945
🌐 IPs únicos atacando: 8
🔥 IP MAIS AGRESSIVO: 177.138.28.7 (1934 tentativas)

🎯 SCORE DE RISCO: 9/13
🚨 RISCO ELEVADO - AÇÃO IMEDIATA NECESSÁRIA
```
⭐ **Se este projeto foi útil, considere dar uma estrela no repositório!**

---

# Vizualização do Menu

<p align="center">
  <img src="https://github.com/user-attachments/assets/6e0d8f80-51dd-4cdc-ac90-49f584553d14" alt="Menu Principal" width="80%">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/aaf0e560-1c3f-4857-b5dc-f44ea9d13ae0" alt="Detecção de Ameaças" width="80%">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/edff9e7b-bfb6-4593-bdce-ccc1084c6d98" alt="Análises Avançadas" width="80%">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/8bfd76fa-5763-4dbb-a34b-1e895440f377" alt="Exportação de Relatórios" width="80%">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/f66647c0-9443-47d1-8403-828b7f737c87" alt="Relatórios Detalhados" width="80%">
</p>

