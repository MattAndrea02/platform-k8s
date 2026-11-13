# Roadmap Ansible

Percorso autonomo per imparare a configurare macchine Linux in modo riproducibile e arrivare ad automatizzare l'infrastruttura. Docker e Kubernetes hanno una [roadmap separata](roadmap-kubernetes.md); non sono necessari per iniziare Ansible.

**Durata indicativa:** 6–8 settimane, con 4–6 ore a settimana. Dedica circa un terzo del tempo alla teoria e il resto al laboratorio. Procedi quando completi la verifica di ogni fase.

## Ambiente e metodo

- Un computer Linux, macOS o ambiente WSL2 per eseguire Ansible, Git e Python 3.
- Una VM Linux con SSH, Python e un utente con accesso sudo; aggiungi una seconda VM quando affronti i gruppi.
- Un ambiente Python isolato con versioni Ansible e dipendenze annotate.
- Un repository con inventory di esempio, playbook, ruoli e README; escludi chiavi private, password e credenziali reali.

Per ogni esercizio salva un commit e annota obiettivo, risultato atteso, errori e soluzione. Usa VM che puoi ricreare.

## Ordine del percorso

| Fase | Argomento | Risultato |
| --- | --- | --- |
| 0 | Linux, SSH, Git e YAML | VM raggiungibile e prerequisiti pronti |
| 1 | Inventory, moduli e primi playbook | Server web configurato |
| 2 | Variabili, template e handler | Configurazione riutilizzabile |
| 3 | Ruoli e collection | Progetto ordinato e dipendenze esplicite |
| 4 | Segreti e verifica | Automazione controllabile e idempotente |
| 5 | Progetto finale Linux | Due VM ricreabili dalla stessa base |
| 6 | Integrazione facoltativa Kubernetes | Bootstrap nodi e deploy applicativo distinti |

## Fase 0 — Prerequisiti

**Studia:** terminale, file e permessi, utenti e gruppi, sudo, pacchetti, servizi `systemd`, log con `journalctl`, IP, porte e DNS. Per YAML: mappe, liste, stringhe e indentazione. Per Git: `status`, `diff`, `add`, `commit` e `.gitignore`.

- [ ] Crea una VM Linux e un utente per l'amministrazione.
- [ ] Configura e verifica SSH con chiave dal control node, mantenendo il controllo della chiave host.
- [ ] Installa manualmente un server web, verifica la risposta con `curl` e consulta i log.
- [ ] Crea il repository del laboratorio.

**Verifica:** sai accedere alla VM, usare sudo e diagnosticare un servizio fermo senza Ansible.

## Fase 1 — Inventory, moduli e primo playbook

**Studia:** control node, managed node, inventory, gruppi, task, play e playbook. Il control node esegue Ansible; l'inventory organizza gli host da gestire. Nel laboratorio Ansible usa SSH e Python per configurare le VM. `become` permette l'elevazione dei privilegi quando necessaria. Riferimento: [introduzione ufficiale Ansible](https://docs.ansible.com/projects/ansible/latest/getting_started/index.html).

- [ ] Installa Ansible in un ambiente isolato e controlla `ansible --version`.
- [ ] Definisci un inventory YAML con indirizzo, utente SSH e gruppo `web`.
- [ ] Controlla i gruppi con `ansible-inventory -i inventory/hosts.yaml --graph`.
- [ ] Verifica la connessione con `ansible.builtin.ping`: prova l'esecuzione del modulo, non un ping ICMP.
- [ ] Scrivi un playbook che installi un server web e ne avvii e abiliti il servizio.
- [ ] Esegui il playbook due volte e confronta `ok`, `changed`, `unreachable` e `failed`.

**Verifica:** sai spiegare l'idempotenza: uno stato già conforme non dovrebbe produrre modifiche inutili.

## Fase 2 — Variabili, template e handler

**Studia:** `group_vars`, `host_vars`, facts, precedenza delle variabili, template Jinja2, handler, loop, `when`, `register` e nomi completi dei moduli, come `ansible.builtin.template`.

- [ ] Parametrizza il messaggio della pagina web e le opzioni del servizio.
- [ ] Genera la configurazione con un template e verifica la sintassi del servizio prima di applicarla, dove supportato.
- [ ] Aggiungi un handler che ricarichi il servizio quando cambia la configurazione.
- [ ] Aggiungi una seconda VM allo stesso gruppo e applica variabili specifiche senza duplicare il playbook.
- [ ] Usa moduli dedicati per pacchetti, file, utenti e servizi; usa `command` o `shell` solo quando necessari, definendo correttamente quando un task cambia stato.

**Verifica:** una modifica alle variabili cambia solo ciò che serve e l'handler viene eseguito quando notificato.

## Fase 3 — Ruoli, collection e organizzazione

**Studia:** struttura dei ruoli, valori di default, task, handler, template, tag e collection. Le collection distribuiscono moduli e altri contenuti riutilizzabili; documentane versioni e dipendenze.

- [ ] Trasforma la configurazione del server web in un ruolo con `tasks`, `handlers`, `templates` e `defaults`.
- [ ] Separa inventory di laboratorio, variabili, ruoli e playbook di ingresso.
- [ ] Introduci un ruolo di base per utenti, pacchetti comuni e configurazioni necessarie alle VM.
- [ ] Registra le collection esterne in `requirements.yaml`, con versioni esplicite.
- [ ] Documenta variabili obbligatorie, valori di default e comando di esecuzione.

**Verifica:** configuri entrambe le VM con ruoli comuni e differenze espresse tramite variabili.

## Fase 4 — Segreti, idempotenza e verifica

**Studia:** Ansible Vault, check mode, diff, lint, `assert`, gestione degli errori e differenza tra un task saltato, riuscito o fallito. Vault protegge dati cifrati: la password di decifratura resta separata dal repository.

- [ ] Cifra una variabile fittizia con Vault e prova a usarla nel laboratorio.
- [ ] Usa `no_log` dove serve e verifica che log, output e diff non espongano credenziali.
- [ ] Esegui `--syntax-check`, poi `--check`; usa `--diff` su configurazioni senza dati sensibili.
- [ ] Esegui `ansible-lint` e correggi i problemi pertinenti.
- [ ] Esegui realmente il playbook sulle VM: il check mode dipende dal supporto dei moduli e non sostituisce questa prova.
- [ ] Modifica manualmente un file gestito, riesegui il playbook e verifica il ripristino.
- [ ] Aggiungi una verifica funzionale HTTP, per esempio con `ansible.builtin.uri` dal nodo appropriato.

**Verifica:** dopo una prima applicazione riuscita, la seconda esecuzione non introduce cambiamenti inattesi e il servizio risponde. Un errore reale emerge come fallimento, senza essere nascosto per far terminare il playbook.

Riferimenti: [check e diff mode](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_checkmode.html) e [Ansible Vault](https://docs.ansible.com/projects/ansible/latest/vault_guide/index.html).

## Fase 5 — Progetto finale Linux

- [ ] Due VM Linux definite nell'inventory e raggiungibili via SSH.
- [ ] Ruolo di base e ruolo web con configurazione parametrizzata e handler.
- [ ] Dipendenze esplicite, variabili documentate e soli segreti fittizi negli esempi pubblicati.
- [ ] Syntax check, lint, prova reale, seconda esecuzione e verifica HTTP completati.
- [ ] README con prerequisiti, creazione delle VM, configurazione SSH, comandi, diagnosi e pulizia.

**Criterio di completamento:** ricrei le VM e le configuri seguendo solo il README, senza correzioni manuali non documentate. Sai spiegare ciascun task e dimostrare che l'automazione ripristina una configurazione alterata.

## Fase 6 — Integrazione facoltativa con Kubernetes

Affrontala dopo aver completato le fasi su kubeadm e CNI della [roadmap Docker e Kubernetes](roadmap-kubernetes.md). Tieni distinti due tipi di automazione:

| Ambito | Connessione | Attività |
| --- | --- | --- |
| Configurazione dei nodi | SSH verso le VM | Sistema operativo, containerd, kubelet, kubeadm e bootstrap |
| Gestione delle risorse | API Kubernetes tramite kubeconfig | Namespace, Deployment, Service, configurazioni e release Helm |

### Preparare i nodi e il cluster

- [ ] Parti dalla procedura manuale già verificata e trasformala in ruoli per base Linux, containerd, control plane e worker.
- [ ] Parametrizza versioni, reti, endpoint API e configurazione del CNI scelto.
- [ ] Esegui `kubeadm init` solo quando appropriato e verifica lo stato effettivo del bootstrap.
- [ ] Gestisci il join dei worker senza conservare token nei log o nel repository.
- [ ] Installa il CNI scelto una sola volta e verifica nodi, DNS e connettività tra Pod.
- [ ] Definisci procedure separate per installazione iniziale, recupero parziale e aggiornamento; cambiare una variabile di versione non costituisce da solo un upgrade corretto.

Il materiale esistente parte da [`ansible/README.md`](ansible/README.md). Secondo quel README il CNI va installato separatamente e le verifiche sulla presenza degli addon non dimostrano la disponibilità dei Pod. Leggi e comprendi i task prima di eseguirli su VM dedicate.

### Distribuire risorse e chart

- [ ] Registra `kubernetes.core` tra le dipendenze e prepara i requisiti Python sul nodo che esegue i moduli.
- [ ] Scrivi un playbook sul control node con connessione locale, kubeconfig e contesto espliciti.
- [ ] Usa `kubernetes.core.k8s` per risorse dichiarative e `kubernetes.core.k8s_info` per leggerne lo stato.
- [ ] Dopo aver imparato Helm, prova `kubernetes.core.helm`, preparando anche il binario Helm richiesto.
- [ ] Attendi la disponibilità dell'applicazione e verifica una risposta HTTP; il successo della richiesta API non dimostra da solo che l'applicazione funzioni.
- [ ] Riesegui i playbook e controlla che non producano modifiche inattese.

**Verifica:** sai separare un problema SSH, un errore del runtime su un nodo e un problema di autenticazione all'API. Ricrei cluster e applicazione con passaggi documentati e verifiche funzionali.

Riferimenti: [Ansible per Kubernetes](https://docs.ansible.com/projects/ansible/latest/collections/kubernetes/core/docsite/kubernetes_scenarios/k8s_intro.html) e [collection kubernetes.core](https://docs.ansible.com/projects/ansible/latest/collections/kubernetes/core/).
