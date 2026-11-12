# Roadmap per iniziare con Kubernetes e Ansible

Un percorso pratico per chi parte da zero o ha poca esperienza di amministrazione Linux. L'obiettivo è imparare a configurare macchine con Ansible, distribuire applicazioni su Kubernetes e collegare le due attività in un laboratorio riproducibile.

**Durata indicativa:** 12 settimane, con 4–6 ore a settimana. Se Linux, reti o container sono nuovi, dedica più tempo alle prime due settimane. Le scadenze sono orientative: passa alla fase successiva quando riesci a completare la verifica senza copiare un tutorial.

## Come seguire il percorso

- Dedica circa un terzo del tempo alla teoria e il resto al laboratorio.
- Conserva manifest, playbook e appunti in Git, con un commit per ogni esercizio completato.
- Per ogni esercizio annota obiettivo, comandi, risultato atteso, errore incontrato e soluzione.
- Lavora su macchine virtuali e cluster di laboratorio che puoi ricreare.
- Usa la documentazione corrispondente alle versioni installate e annota le versioni nel README del laboratorio.

Ansible descrive attività per portare sistemi e servizi allo stato desiderato. Kubernetes mantiene continuamente lo stato desiderato dei carichi di lavoro attraverso i suoi controller. Nel percorso userai prima Ansible per configurare una VM, poi Kubernetes per eseguire un'applicazione, infine Ansible per applicare risorse tramite l'API Kubernetes.

## Ambiente di laboratorio

Prepara gli strumenti progressivamente, quando servono:

| Strumento | Quando | Scopo |
| --- | --- | --- |
| Linux, oppure WSL2 su Windows | Settimana 1 | Terminale, SSH e ambiente di controllo Ansible |
| Git, editor, Python 3 e ambiente virtuale Python | Settimana 1 | Versionamento e dipendenze isolate |
| Una VM Linux con SSH e accesso sudo | Settimana 1 | Macchina gestita da Ansible |
| Docker o Podman | Settimana 2 | Costruzione ed esecuzione di container |
| Ansible | Settimana 3 | Automazione della VM |
| kubectl e minikube | Settimana 6 | Interazione con un cluster locale |
| Collection `kubernetes.core` | Settimana 11 | Integrazione tra Ansible e Kubernetes |

Per partire scegli un solo ambiente Kubernetes: minikube. `kind` è un'alternativa da esplorare successivamente. Non è necessario aprire un account cloud per il percorso di base. Consulta i requisiti del driver scelto e avvia un laboratorio alla volta se le risorse del computer sono limitate. Riferimenti: [ambiente di apprendimento Kubernetes](https://kubernetes.io/docs/setup/learning-environment/) e [avvio di minikube](https://minikube.sigs.k8s.io/docs/start/).

## Calendario

| Settimana | Argomento | Risultato pratico |
| --- | --- | --- |
| 1 | Linux, reti, SSH, Git e YAML | VM raggiungibile e repository del laboratorio |
| 2 | Container | Applicazione avviata da un'immagine riproducibile |
| 3 | Fondamenti Ansible | Primo playbook su una VM |
| 4 | Playbook riutilizzabili | Configurazione parametrizzata con handler e template |
| 5 | Ruoli e verifica Ansible | Automazione ordinata e idempotente |
| 6 | Architettura Kubernetes e kubectl | Cluster locale e primo Deployment |
| 7 | Applicazioni e connettività | Servizio raggiungibile e aggiornamento verificato |
| 8 | Configurazione, storage e salute | Applicazione configurata e dati persistenti |
| 9 | Diagnosi e accessi | Guasti risolti e permessi limitati |
| 10 | Manifest per più ambienti | Configurazioni dev e test con Kustomize |
| 11 | Ansible e API Kubernetes | Distribuzione automatizzata dell'applicazione |
| 12 | Progetto finale | Laboratorio ricreabile e documentato |

## Settimana 1 — Prerequisiti

**Studia:** file e directory Linux, permessi, utenti e gruppi, processi, pacchetti, servizi `systemd`, log con `journalctl`, variabili d'ambiente e pipe. Per le reti: indirizzi IP, subnet, porte, DNS, HTTP/HTTPS e differenza tra `localhost` e indirizzo di una VM. Per YAML: mappe, liste, indentazione e stringhe. Per Git: `status`, `diff`, `add`, `commit` e `.gitignore`.

**Laboratorio:**

- [ ] Crea una VM Linux e un utente con accesso sudo.
- [ ] Configura l'accesso SSH con chiave dal computer di lavoro.
- [ ] Installa manualmente un server web sulla VM e verifica la risposta con `curl`.
- [ ] Individua servizio, porta in ascolto e log del server.
- [ ] Crea un repository per gli esercizi ed escludi chiavi private, credenziali e kubeconfig.

**Verifica:** sai spiegare come una richiesta dal tuo computer raggiunge il server web e sai diagnosticare un servizio fermo.

## Settimana 2 — Container prima di Kubernetes

**Studia:** differenza tra immagine e container, Dockerfile, registry, tag, porte pubblicate, variabili d'ambiente e volumi. Distingui il filesystem del container dai dati conservati in un volume.

**Laboratorio:**

- [ ] Avvia un container web, esponi una porta e consulta i log.
- [ ] Costruisci un'immagine per una piccola applicazione HTTP o una pagina statica.
- [ ] Assegna un tag esplicito all'immagine e annota come ricostruirla.
- [ ] Prova un volume e verifica cosa succede ai dati ricreando il container.

**Verifica:** ricostruisci e avvii l'applicazione seguendo solo il tuo README. Sai distinguere una porta del container da una porta dell'host.

## Settimana 3 — Primo contatto con Ansible

**Studia:** control node, managed node, inventory, gruppi, moduli, task, play e playbook. Comprendi come Ansible usa SSH e Python per gestire una VM Linux e quando serve `become` per elevare i privilegi. Segui la [guida introduttiva ufficiale Ansible](https://docs.ansible.com/projects/ansible/latest/getting_started/index.html).

**Laboratorio:**

- [ ] Installa Ansible in un ambiente isolato e controlla `ansible --version`.
- [ ] Definisci un inventory con la VM della settimana 1.
- [ ] Verifica la connessione con `ansible.builtin.ping`: controlla l'esecuzione del modulo, non un ping ICMP.
- [ ] Scrivi un playbook che installi il server web e ne abiliti il servizio.
- [ ] Esegui il playbook due volte e confronta `ok`, `changed` e `failed`.

**Verifica:** spieghi il concetto di idempotenza: a stato già conforme, i task non dovrebbero introdurre modifiche inutili.

## Settimana 4 — Playbook riutilizzabili

**Studia:** variabili, `group_vars`, `host_vars`, facts, template Jinja2, handler, loop, condizioni `when`, `register` e nomi completi dei moduli, come `ansible.builtin.template`.

**Laboratorio:**

- [ ] Parametrizza un messaggio della pagina web e il nome del pacchetto da installare.
- [ ] Genera un file di configurazione con un template.
- [ ] Aggiungi un handler che ricarichi il servizio quando cambia la configurazione.
- [ ] Se hai risorse disponibili, aggiungi una seconda VM allo stesso gruppo.
- [ ] Usa moduli dedicati per pacchetti, file e servizi; riserva `command` e `shell` ai casi che li richiedono.

**Verifica:** cambiando una variabile ottieni una configurazione diversa senza duplicare il playbook; l'handler interviene solo quando viene notificato.

## Settimana 5 — Organizzare e verificare Ansible

**Studia:** ruoli, tag, collection, file di dipendenze e Ansible Vault. Vault protegge dati cifrati nel repository: la password di decifratura va conservata separatamente.

**Laboratorio:**

- [ ] Sposta la configurazione del server web in un ruolo con `tasks`, `handlers`, `templates` e `defaults`.
- [ ] Documenta inventory, variabili richieste e comando di esecuzione.
- [ ] Esegui `--syntax-check`, poi prova `--check` sul laboratorio; valuta `--diff` solo su file senza dati sensibili.
- [ ] Esegui `ansible-lint` e correggi i problemi pertinenti.
- [ ] Cambia manualmente un file gestito e verifica che il playbook ripristini la configurazione prevista.

**Verifica:** su una VM già conforme, una seconda esecuzione termina senza errori e senza modifiche inattese. Il check mode dipende dal supporto dei moduli e non sostituisce una prova reale.

## Settimana 6 — Fondamenti Kubernetes

**Studia:** cluster, control plane, worker, API server, etcd, scheduler, controller, kubelet e runtime dei container. Introduci Namespace, Pod, Deployment, ReplicaSet, label e selector. Parti dal percorso [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/).

**Laboratorio:**

- [ ] Installa kubectl e avvia un cluster minikube seguendo la documentazione ufficiale.
- [ ] Controlla il contesto attivo con `kubectl config current-context` e i nodi con `kubectl get nodes`.
- [ ] Crea un namespace dedicato agli esercizi.
- [ ] Crea un Deployment web da un manifest YAML e osserva Pod e ReplicaSet.
- [ ] Elimina un Pod del Deployment e osserva la sua ricreazione.

**Verifica:** sai spiegare perché il Deployment ricrea il Pod e perché modificare solo un container in esecuzione non aggiorna il manifest nel repository.

## Settimana 7 — Distribuire e raggiungere un'applicazione

**Studia:** Service, ClusterIP, NodePort, DNS interno, porte e selector; scaling, rolling update e rollback. Per l'accesso HTTP dall'esterno, esplora Gateway API con un'implementazione compatibile: le sole risorse API non forniscono il traffico senza un controller.

**Laboratorio:**

- [ ] Rendi disponibile al cluster l'immagine della settimana 2, caricandola nel cluster locale o usando un registry raggiungibile.
- [ ] Distribuisci l'applicazione e crea un Service ClusterIP con i selector corretti.
- [ ] Accedi dal computer con `kubectl port-forward` e prova la risoluzione DNS da un Pod di test.
- [ ] Porta il Deployment a due repliche.
- [ ] Distribuisci una nuova versione con tag distinto, controlla il rollout e prova il rollback.

**Verifica:** sai ricostruire il percorso della richiesta fino al Pod e riconoscere un Service che non seleziona alcun Pod.

## Settimana 8 — Configurazione, storage e affidabilità

**Studia:** ConfigMap, Secret, volumi, PersistentVolumeClaim e StorageClass; readiness, liveness e startup probe; richieste e limiti di CPU e memoria. La codifica base64 dei Secret non è cifratura: usa valori fittizi negli esercizi pubblicati.

**Laboratorio:**

- [ ] Esternalizza una configurazione in una ConfigMap e verifica come viene recepita dall'applicazione.
- [ ] Configura un Secret di esempio senza inserire credenziali reali in Git.
- [ ] Aggiungi probe compatibili con gli endpoint effettivi dell'applicazione.
- [ ] Definisci richieste e limiti coerenti con il piccolo cluster locale.
- [ ] Prova separatamente un'applicazione con PVC e verifica la persistenza ricreando il Pod senza eliminare il claim.

**Verifica:** sai distinguere un Pod avviato da uno pronto a ricevere traffico e spiegare perché un volume persistente non sostituisce un backup.

## Settimana 9 — Troubleshooting e accessi

**Studia:** eventi, log e stato delle risorse; ServiceAccount, Role e RoleBinding; principio del minimo privilegio e uso di un utente non root nei container.

**Laboratorio:**

- [ ] Introduci un tag immagine inesistente e diagnostica `ImagePullBackOff`.
- [ ] Provoca un arresto dell'applicazione e indaga `CrashLoopBackOff`, anche con i log dell'istanza precedente.
- [ ] Crea una richiesta di risorse eccessiva e analizza perché il Pod resta `Pending`.
- [ ] Rompi il selector del Service e ripristina la connettività.
- [ ] Crea un ruolo con sola lettura dei Pod nel namespace e verifica permessi concessi e negati con `kubectl auth can-i`.

**Metodo:** controlla prima contesto e namespace, poi `get`, `describe`, eventi e `logs`; usa `logs --previous` dopo un riavvio ed `exec` quando il container e i suoi strumenti lo consentono.

**Verifica:** risolvi almeno tre guasti e documenti per ciascuno sintomo, causa, diagnosi e correzione.

## Settimana 10 — Gestire manifest per più ambienti

**Studia:** Kustomize, basi e overlay. Introduci Helm come strumento per installare pacchetti applicativi; approfondiscilo dopo aver capito i manifest generati.

**Laboratorio:**

- [ ] Organizza i manifest in una base e due overlay, `dev` e `test`.
- [ ] Differenzia namespace, repliche e configurazione senza copiare tutti i file.
- [ ] Esamina il risultato con `kubectl kustomize` prima di applicarlo.
- [ ] Prova `kubectl diff -k` sul laboratorio, evitando manifest contenenti segreti reali.
- [ ] Documenta ordine di applicazione, aggiornamento e rimozione delle risorse.

**Verifica:** distribuisci la stessa applicazione nei due ambienti e sai spiegare le differenze introdotte dagli overlay.

## Settimana 11 — Integrare Ansible e Kubernetes

**Studia:** collection `kubernetes.core`, autenticazione tramite kubeconfig, modulo `kubernetes.core.k8s` e lettura dello stato con `kubernetes.core.k8s_info`. I moduli richiedono dipendenze Python sul nodo dove vengono eseguiti: consulta i requisiti della versione scelta nella [guida Ansible per Kubernetes](https://docs.ansible.com/projects/ansible/latest/collections/kubernetes/core/docsite/kubernetes_scenarios/k8s_intro.html).

**Laboratorio:**

- [ ] Registra la collection in un file di dipendenze e installala con `ansible-galaxy collection install -r requirements.yaml`.
- [ ] Prepara le dipendenze Python nell'ambiente usato da Ansible.
- [ ] Scrivi un playbook eseguito sul control node con connessione locale, kubeconfig e contesto espliciti.
- [ ] Usa `kubernetes.core.k8s` per creare namespace e risorse applicative, riutilizzando i manifest studiati.
- [ ] Attendi il completamento del rollout e verifica una risposta HTTP dell'applicazione.
- [ ] Riesegui il playbook e controlla che lo stato resti conforme.

**Verifica:** ricrei le risorse applicative in un namespace di laboratorio vuoto con una procedura documentata. Sai distinguere la configurazione di una VM via SSH dalla gestione delle risorse tramite API Kubernetes.

## Settimana 12 — Progetto finale

Realizza un laboratorio per una piccola applicazione HTTP, riutilizzando il lavoro delle settimane precedenti.

**Consegne:**

- [ ] Ruolo Ansible che configura una VM Linux e un servizio dimostrativo.
- [ ] Dockerfile dell'applicazione e istruzioni per costruire e rendere disponibile l'immagine al cluster.
- [ ] Manifest Kubernetes con Deployment, Service, ConfigMap, probe e risorse; esercizio PVC separato e riproducibile.
- [ ] Playbook Ansible che distribuisce e verifica l'applicazione sul cluster locale.
- [ ] Dipendenze e versioni annotate, variabili documentate e soli segreti fittizi negli esempi.
- [ ] README con prerequisiti, creazione del cluster, configurazione della VM, deploy, aggiornamento, rollback e pulizia.
- [ ] Appunti su almeno tre problemi risolti durante il percorso.

**Criteri di completamento:**

1. Ricrei il laboratorio seguendo solo il README, senza passaggi manuali non documentati.
2. La VM viene configurata e l'applicazione risponde tramite il Service usando port-forward.
3. Una seconda esecuzione dei playbook non produce modifiche inattese.
4. Un aggiornamento errato viene riconosciuto e recuperato con un rollback verificato.
5. Sai spiegare il ruolo di ogni componente e rimuovere le risorse del laboratorio che hai creato.

## Collegamento a questo repository

La directory [`ansible/`](ansible/) contiene già materiale per configurare un control plane Kubernetes con kubeadm. Il punto di ingresso documentato è [`ansible/README.md`](ansible/README.md).

Usalo come approfondimento dopo il percorso di base: leggi inventory, variabili, dipendenze e task, poi descrivi cosa fa ogni fase prima di eseguirla su VM dedicate. Secondo il README, il CNI va installato separatamente e la presenza degli addon non dimostra che tutti i Pod siano disponibili.

Questo laboratorio aggiunge l'amministrazione dei nodi e l'installazione del cluster. Il progetto finale di base usa invece un cluster locale creato con minikube e automatizza le risorse applicative.

## Dopo le basi

Scegli un approfondimento in base al tuo obiettivo:

| Obiettivo | Passi successivi |
| --- | --- |
| Amministrare cluster | kubeadm su più VM, runtime, CNI, aggiornamenti, backup e ripristino di etcd |
| Distribuire applicazioni | Helm, pipeline CI/CD, GitOps, gestione immagini e strategie di rilascio |
| Migliorare l'affidabilità | Metriche, log centralizzati, alert, autoscaling e prove di recupero |
| Rafforzare la sicurezza | RBAC, Pod Security Standards, NetworkPolicy con CNI compatibile e gestione dei segreti |
| Approfondire Ansible | Ruoli riutilizzabili, test con Molecule, inventory dinamici ed execution environment |

Non serve affrontare tutti questi argomenti insieme: scegli il prossimo esercizio a partire da un problema concreto del tuo laboratorio.
