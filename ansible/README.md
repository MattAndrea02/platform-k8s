# Control plane

Eseguire dalla directory `ansible`:

```bash
ansible-galaxy collection install -r requirements.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/control_plane_playbook.yaml
```

I parametri sono in `inventory/group_vars/master.yaml`, caricato automaticamente
per il gruppo `master`. Connessione SSH e indirizzi restano in `inventory/hosts.yaml`.
È possibile sovrascrivere i parametri con `-e` o nelle variabili dell'host.
`kubernetes_version` seleziona il repository minor; non aggiorna automaticamente
i pacchetti Kubernetes già installati e bloccati con hold.

Ordine: prerequisiti e account → repository e pacchetti Kubernetes → forwarding
e configurazione kubelet → containerd → kubelet → kubeadm → verifica API, RBAC
e presenza degli addon → configurazione kubectl per root.

`kubelet_fail_swap_on: false` permette l'avvio con swap attiva.
Gli eventuali altri flag vanno in `kubelet_extra_args`.

Il playbook evita di ripetere `kubeadm init` su un cluster esistente, ma verifica
separatamente che l'inizializzazione sia completa. Se una precedente esecuzione
si è interrotta, segnala il controllo fallito: le fasi mancanti vanno recuperate
prima di considerare il cluster inizializzato. La verifica degli addon controlla
la loro presenza, non la disponibilità dei pod: il CNI va installato separatamente.

Verifiche senza applicare modifiche:

```bash
ansible-playbook playbooks/control_plane_playbook.yaml --syntax-check
ansible-playbook playbooks/control_plane_playbook.yaml --check
```
