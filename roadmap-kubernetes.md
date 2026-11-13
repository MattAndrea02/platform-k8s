# Roadmap Docker e Kubernetes

Percorso per partire dalle basi e arrivare a creare e gestire un cluster con kubeadm, containerd e un CNI scelto esplicitamente. Ansible ha una [roadmap separata](roadmap-ansible.md): non è un prerequisito per questo percorso.

**Ritmo indicativo:** 4–6 ore a settimana per 12–16 settimane, aumentando il tempo se Linux e reti sono nuovi. Le fasi contano più delle scadenze: passa alla successiva quando completi la verifica senza copiare un tutorial.

## Ordine del percorso

| Fase | Argomento | Risultato |
| --- | --- | --- |
| 0 | Linux, reti, Git e YAML | Ambiente e prerequisiti pronti |
| 1 | Docker e containerd | Applicazione containerizzata e runtime compreso |
| 2 | Basi Kubernetes: kubelet, kubectl e componenti | Cluster locale e architettura compresa |
| 3 | Primo deploy e Service | Applicazione raggiungibile con port-forward |
| 4 | Ingress e LoadBalancer | Accesso HTTP tramite nome host e IP esterno |
| 5 | PostgreSQL | Database persistente e ripristino verificato |
| 6 | ConfigMap, Secret e Reflector | Configurazione sincronizzata tra namespace |
| 7 | Helm | Applicazione confezionata in un chart |
| 8 | Cluster da zero con kubeadm e CNI dedicato | Control plane e worker su VM |
| 9 | Gestione del cluster | Manutenzione, diagnosi e aggiornamento |
| 10 | Progetto finale | Stack completo ricreabile e documentato |

Inizia con minikube per concentrarti sulle applicazioni; nella fase 8 ricrea l'ambiente su VM Linux. Salva manifest, versioni e appunti in Git. Per ogni prova annota risultato atteso, errore e soluzione.

## Fase 0 — Prerequisiti

**Da capire:** file, permessi, utenti, sudo, processi, pacchetti, servizi `systemd`, SSH e `journalctl`. Per le reti: IP, subnet, routing, DNS, porte TCP, HTTP/HTTPS, localhost e firewall. Per YAML: mappe, liste e indentazione. Per Git: commit, diff e `.gitignore`.

- [ ] Prepara Linux o WSL2 su Windows, Git e un editor.
- [ ] Raggiungi una VM Linux con SSH e consulta log e porte in ascolto.
- [ ] Prova `curl`, `ss` e uno strumento di risoluzione DNS.
- [ ] Crea il repository del laboratorio, escludendo credenziali e kubeconfig.

**Verifica:** sai spiegare la differenza tra un servizio fermo, una porta bloccata e un nome DNS non risolto.

## Fase 1 — Docker e cosa è containerd

**Da capire:** un'immagine è il modello distribuito tramite un registry; un container è un'istanza in esecuzione con processi isolati. Studia Dockerfile, layer, build context, tag, digest, reti, porte, variabili e volumi. Un volume conserva dati oltre la vita del container.

**containerd** è un runtime che gestisce immagini e ciclo di vita dei container e usa runtime OCI, come `runc`, per avviare i processi. Docker Engine usa containerd al suo interno e aggiunge strumenti per build, reti e gestione tramite la CLI Docker. Kubernetes può usare containerd direttamente tramite CRI, senza installare Docker Engine sui nodi. Le immagini costruite con Docker possono essere eseguite anche da containerd. Riferimento: [runtime dei container in Kubernetes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/).

- [ ] Installa Docker e avvia un container web con una porta pubblicata.
- [ ] Costruisci un'immagine di una piccola applicazione HTTP con tag esplicito.
- [ ] Leggi i log, entra nel container e verifica le variabili d'ambiente.
- [ ] Prova un volume, elimina il container e ricrealo mantenendo i dati.
- [ ] Prova Docker Compose per collegare due servizi; distingui la rete Compose da quella Kubernetes.
- [ ] Disegna i due percorsi: Docker CLI → Docker Engine → containerd; kubelet → CRI → containerd.

**Verifica:** ricostruisci e avvii l'applicazione seguendo il tuo README e sai spiegare perché su un nodo Kubernetes potresti non trovare il comando `docker`.

Riferimento per gli esercizi: [introduzione ufficiale a Docker](https://docs.docker.com/get-started/).

## Fase 2 — Basi Kubernetes e differenze tra kubelet e kubectl

**Da capire:** stato desiderato, riconciliazione, cluster, nodi, control plane, Pod, Deployment, ReplicaSet, Namespace, label e selector.

| Componente | Dove si usa o gira | Responsabilità |
| --- | --- | --- |
| `kubectl` | Sul computer dell'operatore o in una pipeline | Client della API Kubernetes: legge e modifica risorse usando kubeconfig e permessi RBAC |
| `kubelet` | Come servizio su ogni nodo | Gestisce i Pod assegnati al nodo, interagisce con il runtime e comunica lo stato |
| `kubeadm` | Sui nodi durante bootstrap e manutenzione | Inizializza il control plane, aggiunge nodi e supporta operazioni di aggiornamento |
| `containerd` | Come servizio su ogni nodo del laboratorio | Scarica immagini ed esegue i container richiesti tramite CRI |
| API server | Nel control plane | Espone l'API usata dai client e dai componenti |
| etcd | Associato al control plane | Conserva lo stato del cluster |
| Scheduler e controller | Nel control plane | Scelgono dove eseguire i Pod e riconciliano le risorse |

Quando lanci `kubectl apply`, kubectl invia una richiesta all'API server. I controller e lo scheduler intervengono sullo stato del cluster; il kubelet del nodo assegnato fa eseguire i container tramite il runtime. Chiudere kubectl non ferma il cluster. Riferimento: [componenti Kubernetes](https://kubernetes.io/docs/concepts/overview/components/).

- [ ] Installa kubectl e minikube seguendo i requisiti del driver scelto.
- [ ] Avvia il cluster e controlla contesto, nodi e Pod di sistema.
- [ ] Crea il namespace `app-dev` e impara a specificarlo nei comandi.
- [ ] Leggi un manifest distinguendo `apiVersion`, `kind`, `metadata` e `spec`.

**Verifica:** sai descrivere chi riceve il comando, chi assegna il Pod al nodo e chi ne avvia i container.

Riferimenti: [avvio minikube](https://minikube.sigs.k8s.io/docs/start/) e [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/).

## Fase 3 — Primo deploy di un servizio

**Da capire:** Deployment per gestire le repliche; Service per fornire un punto di accesso stabile ai Pod selezionati. Distingui `port`, `targetPort`, ClusterIP e NodePort. Il Service inoltra traffico: non avvia l'applicazione. Riferimento: [Service Kubernetes](https://kubernetes.io/docs/concepts/services-networking/service/).

- [ ] Rendi disponibile l'immagine Docker al cluster locale o a un registry raggiungibile.
- [ ] Scrivi `deployment.yaml` e `service.yaml` per la tua applicazione HTTP.
- [ ] Aggiungi una readiness probe e richieste/limiti compatibili con il laboratorio.
- [ ] Applica i manifest nel namespace `app-dev` e controlla il rollout.
- [ ] Accedi con `kubectl -n app-dev port-forward service/web 8080:80`, adattando nome e porta al tuo Service.
- [ ] Porta l'applicazione a due repliche ed elimina un Pod per osservarne la ricreazione.
- [ ] Cambia il tag immagine, verifica il rolling update e prova un rollback.
- [ ] Rompi un selector e usa Pod, Service ed EndpointSlice per trovare il problema.

**Verifica:** l'applicazione risponde, il Deployment ricrea un Pod eliminato e sai diagnosticare un Service senza endpoint.

## Fase 4 — Ingress e LoadBalancer

**Da capire:** un Ingress descrive regole HTTP/HTTPS per host e percorsi; un Ingress controller le implementa. Un Service di tipo LoadBalancer richiede un'implementazione che fornisca l'accesso esterno. Creare questi oggetti da soli non installa controller né assegna automaticamente un IP in ogni ambiente.

Percorso da ricostruire: **client → IP del LoadBalancer → Service del controller → Ingress controller → backend selezionato dal Service applicativo → Pod**. Il controller può inoltrare direttamente agli endpoint del backend, secondo la sua implementazione.

- [ ] Installa un controller, per esempio Traefik, con il provider Kubernetes Ingress abilitato e manifest della versione scelta. Approfondirai Helm nella fase 7.
- [ ] Esponi il controller tramite Service LoadBalancer. Con minikube usa `minikube tunnel`, verificando la raggiungibilità dell'IP dal computer.
- [ ] Crea una risorsa Ingress con `ingressClassName` coerente con il controller, host `web.lab.test` e backend `web`.
- [ ] Configura DNS locale o file hosts verso l'IP raggiungibile e verifica header Host e routing.
- [ ] Aggiungi un secondo percorso o host per capire come vengono scelte le destinazioni.
- [ ] Prova HTTPS con un certificato di laboratorio e relativo Secret TLS; capirai i Secret in dettaglio nella fase 6.
- [ ] Comprendi il caso bare metal: con MetalLB servono un `IPAddressPool` e una configurazione di annuncio, per esempio `L2Advertisement`; gli IP devono essere liberi e raggiungibili nella rete scelta.

**Verifica:** raggiungi l'applicazione tramite host senza port-forward e distingui un IP esterno assente, un errore di routing Ingress e un backend non pronto.

L'API Ingress è congelata e Kubernetes raccomanda Gateway API per le evoluzioni. Studia comunque Ingress in questa fase, poi confronta i due modelli. Riferimenti: [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/), [Traefik Kubernetes Ingress](https://doc.traefik.io/traefik/reference/routing-configuration/kubernetes/ingress/) e [configurazione MetalLB](https://metallb.io/configuration/).

## Fase 5 — PostgreSQL e persistenza

**Da capire:** storage effimero e persistente, PV, PVC, StorageClass, provisioner, access mode e reclaim policy. Uno StatefulSet dà identità e storage stabili ai Pod; non configura da solo replica e failover PostgreSQL. Parti da una sola istanza. Riferimento: [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/).

- [ ] Verifica che il cluster abbia una StorageClass utilizzabile.
- [ ] Distribuisci PostgreSQL con versione esplicita, StatefulSet a una replica, PVC e Service interno. Configura anche il Service headless per l'identità dello StatefulSet.
- [ ] Introduci il minimo necessario dei Secret: credenziali fittizie referenziate dal workload, senza valori reali in Git. Nella prossima fase approfondirai configurazione e sincronizzazione.
- [ ] Verifica nella documentazione dell'immagine scelta dove montare il volume dati e quali variabili inizializzano il database.
- [ ] Collega l'applicazione al database tramite DNS del Service; crea una tabella e inserisci dati.
- [ ] Ricrea solo il Pod mantenendo il PVC e controlla che i dati siano presenti.
- [ ] Crea un backup con `pg_dump`, poi ripristinalo in un database di prova e verifica i dati.
- [ ] Osserva cosa succede al PVC rimuovendo il workload e documenta la policy di conservazione scelta.

**Verifica:** l'applicazione legge e scrive dati, il riavvio del Pod non li perde e hai provato un ripristino. Un PVC non è un backup; uno storage locale non rende i dati disponibili su qualsiasi nodo. Per alta disponibilità del database, approfondisci successivamente un operator PostgreSQL.

Riferimento per backup e ripristino: [PostgreSQL SQL Dump](https://www.postgresql.org/docs/current/backup-dump.html).

## Fase 6 — ConfigMap, Secret e copie sincronizzate con Reflector

**Da capire:** ConfigMap per configurazioni non sensibili, Secret per dati sensibili, riferimenti da variabili d'ambiente e volumi. Sono risorse legate al namespace. La codifica base64 dei Secret non è cifratura; controlla anche RBAC e protezione dei dati a riposo.

**Reflector** osserva una ConfigMap o un Secret sorgente e sincronizza copie nei namespace autorizzati. Qui “ridondanza” significa copie sincronizzate tra namespace: non backup, alta disponibilità o replica del database. Riferimento: [Reflector di EmberStack](https://github.com/emberstack/kubernetes-reflector).

- [ ] Sposta la configurazione dell'applicazione in ConfigMap e Secret, distinguendo valori condivisi da credenziali specifiche di un ambiente.
- [ ] Crea i namespace `shared-config`, `app-dev` e `app-test`.
- [ ] Installa Reflector usando il manifest di una release precisa; annota versione e origine. Passerai alla gestione Helm nella fase successiva.
- [ ] Aggiungi queste annotazioni alla risorsa sorgente in `shared-config`:

  ```yaml
  metadata:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "^app-dev$,^app-test$"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "^app-dev$,^app-test$"
  ```

- [ ] Verifica le copie con lo stesso nome nei due namespace; prova sia ConfigMap sia Secret con dati fittizi.
- [ ] Modifica la sorgente e verifica la propagazione, poi prova la cancellazione su risorse sacrificabili.
- [ ] Verifica che un namespace escluso non riceva copie e consulta i log del controller in caso di conflitto di nomi.
- [ ] Studia come l'applicazione recepisce gli aggiornamenti: le variabili d'ambiente richiedono nuovi Pod; i volumi possono aggiornarsi con ritardo e l'applicazione deve rileggere i file. I mount `subPath` non ricevono questi aggiornamenti automatici.

**Verifica:** un aggiornamento della sorgente arriva solo alle destinazioni previste; sai distinguere la sincronizzazione della risorsa dal riavvio o reload dell'applicazione. Modifica la sorgente, evitando cambi manuali alle copie gestite.

Riferimenti per il consumo delle risorse: [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/) e [Secret](https://kubernetes.io/docs/concepts/configuration/secret/).

## Fase 7 — Helm dopo i manifest

**Da capire:** chart, release, repository/registry OCI, `Chart.yaml`, `values.yaml`, template, dipendenze e differenza tra versione del chart e dell'applicazione. Riferimento: [uso di Helm](https://helm.sh/docs/intro/using_helm/).

- [ ] Installa una versione Helm compatibile con i chart scelti e annotala.
- [ ] Trasforma i manifest dell'applicazione in un chart con Deployment, Service, Ingress e riferimenti a ConfigMap/Secret.
- [ ] Crea file values separati per `dev` e `test` senza inserirvi segreti reali.
- [ ] Controlla il chart con `helm lint` e ispeziona i manifest con `helm template`.
- [ ] Installa una release, modifica immagine o repliche e prova `helm upgrade`, `helm history` e `helm rollback`.
- [ ] In un laboratorio pulito, gestisci Reflector con il suo chart ufficiale e versione esplicita. Non installare una seconda istanza sulle risorse già gestite dai manifest senza pianificarne la migrazione.
- [ ] Distingui le risorse dell'applicazione dai componenti condivisi, come controller Ingress e Reflector.

**Verifica:** distribuisci la stessa applicazione nei due namespace usando values diversi. Sai spiegare perché un rollback Helm non ripristina automaticamente i dati PostgreSQL né annulla una migrazione dello schema.

## Fase 8 — Cluster da zero: kubeadm, containerd e CNI dedicato

Ora ricrea il laboratorio su **tre VM Linux: un control plane e due worker**, con IP stabili e connettività reciproca. Questo primo cluster ha un singolo control plane; l'alta disponibilità richiede un progetto successivo.

### 8.1 — Preparare le macchine

- [ ] Pianifica rete dei nodi, Pod CIDR e Service CIDR senza sovrapposizioni con LAN, VPN e altre reti del laboratorio.
- [ ] Verifica hostname univoci, risoluzione dei nomi, sincronizzazione oraria, porte richieste e requisiti del sistema operativo.
- [ ] Per il primo laboratorio disabilita la swap e comprendi perché configurazioni con swap richiedono scelte esplicite e compatibili.
- [ ] Installa containerd, abilita CRI e allinea il driver cgroup di runtime e kubelet, normalmente `systemd` su questi sistemi. Usa la configurazione adatta alla versione containerd installata.
- [ ] Configura moduli kernel e forwarding secondo i requisiti di Kubernetes e del CNI scelto.
- [ ] Installa versioni compatibili di kubeadm e kubelet sui nodi; prepara kubectl sulla macchina di amministrazione e, se utile, sul control plane.

**Verifica:** containerd è attivo, il runtime risponde con `crictl` configurato sul suo endpoint CRI e sai leggere i log di runtime e kubelet. Prima del bootstrap il kubelet può riavviarsi in attesa della sua configurazione.

Riferimenti: [installazione kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) e [configurazione dei runtime](https://kubernetes.io/docs/setup/production-environment/container-runtimes/).

### 8.2 — Inizializzare e collegare i nodi

- [ ] Prepara un file di configurazione kubeadm con endpoint API, versione, reti e socket CRI espliciti.
- [ ] Esegui `kubeadm init` sul control plane e configura il kubeconfig dell'operatore.
- [ ] Comprendi i certificati creati e il ruolo dei manifest statici in `/etc/kubernetes/manifests`.
- [ ] Installa il CNI della sezione seguente e usa `kubeadm join` per aggiungere i worker.
- [ ] Verifica API, stato dei nodi, Pod di sistema e DNS, senza considerare il solo successo di `init` come verifica completa.

Riferimento: [creazione di un cluster con kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).

### 8.3 — Installare un CNI scelto: Calico

**CNI** significa Container Network Interface. Un plugin di rete implementa la connettività dei Pod; kubeadm non installa automaticamente la rete dei Pod. Per questo percorso scegli **Calico**, verifica la compatibilità con Kubernetes e usa una sola implementazione di rete dei Pod nel laboratorio. Cilium sarà un confronto successivo.

- [ ] Leggi i requisiti Calico e scegli una modalità di rete compatibile con le VM.
- [ ] Installa Calico da una release precisa e allinea il pool IP dei Pod al piano di rete.
- [ ] Controlla componenti Calico, nodi `Ready` e CoreDNS operativo.
- [ ] Prova Pod su nodi diversi, DNS interno e accesso a un Service.
- [ ] Aggiungi una NetworkPolicy che consenta al database solo il traffico previsto e verifica sia accessi consentiti sia negati.

**Verifica:** spieghi la differenza tra CNI per la rete dei Pod, implementazione della rete dei Service e MetalLB per l'esposizione esterna. Calico è il CNI scelto per il tuo cluster, non un CNI aggiuntivo da affiancare senza progetto a quello esistente. Riferimento: [guida Calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart).

### 8.4 — Riportare lo stack sul nuovo cluster

- [ ] Installa un provisioner di storage: kubeadm non fornisce automaticamente una StorageClass con provisioning dinamico.
- [ ] Su una rete VM compatibile, configura MetalLB con un pool riservato e annunci L2 verificabili dal client.
- [ ] Installa controller Ingress e Reflector e distribuisci il chart applicativo.
- [ ] Ripeti le verifiche HTTP, PostgreSQL, PVC e copie tra namespace. Scegli storage che soddisfi i requisiti del database: un volume locale resta legato al nodo.

## Fase 9 — Gestione del cluster kubeadm

- [ ] Impara a diagnosticare `NotReady`, Pod `Pending`, `ImagePullBackOff`, `CrashLoopBackOff` e problemi di rete usando eventi, log e stato dei componenti.
- [ ] Prova `cordon`, `drain` e `uncordon` su un worker, verificando replica, PodDisruptionBudget e vincoli dello storage.
- [ ] Controlla scadenza dei certificati con `kubeadm certs check-expiration` e studia il rinnovo.
- [ ] Prepara e prova backup/ripristino di etcd in un laboratorio isolato; separali dai backup PostgreSQL e dei volumi.
- [ ] Pianifica un aggiornamento supportato: verifica compatibilità e version skew, usa `kubeadm upgrade plan`, aggiorna prima il control plane e poi i worker uno alla volta con drain e verifica. Segui la procedura della versione di partenza, senza saltare minor version.
- [ ] Crea accessi RBAC limitati e verifica permessi concessi e negati con `kubectl auth can-i`.
- [ ] Documenta recupero di un worker e differenza tra ricreare un nodo e recuperare i suoi dati.

**Verifica:** completi una manutenzione su un worker e descrivi limiti e tempi di recupero del laboratorio, inclusi il singolo control plane e lo storage scelto.

Riferimenti: [aggiornamenti kubeadm](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/) e [backup di etcd](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/).

## Fase 10 — Progetto finale e criteri di completamento

- [ ] Repository con Dockerfile, chart, values di esempio, configurazione Reflector e procedura kubeadm/CNI.
- [ ] Applicazione raggiungibile tramite Ingress e LoadBalancer, collegata a PostgreSQL persistente.
- [ ] ConfigMap e Secret di prova sincronizzati esclusivamente nei namespace autorizzati.
- [ ] Backup PostgreSQL ripristinato e aggiornamento/rollback applicativo verificati.
- [ ] README con prerequisiti, versioni, reti, storage, installazione, diagnosi e pulizia del laboratorio.
- [ ] Ricostruzione del cluster e dello stack seguendo solo il README, senza passaggi impliciti.

Dopo aver eseguito manualmente e compreso il bootstrap, usa la [roadmap Ansible](roadmap-ansible.md) per automatizzarlo. In questo repository il materiale esistente per il control plane è descritto in [`ansible/README.md`](ansible/README.md); il README indica che il CNI va installato separatamente e distingue la presenza degli addon dalla disponibilità dei Pod.
