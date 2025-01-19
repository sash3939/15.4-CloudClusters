# Домашнее задание к занятию «Кластеры. Ресурсы под управлением облачных провайдеров»

### Цели задания 

1. Организация кластера Kubernetes и кластера баз данных MySQL в отказоустойчивой архитектуре.
2. Размещение в private подсетях кластера БД, а в public — кластера Kubernetes.

---
## Задание 1. Yandex Cloud

1. Настроить с помощью Terraform кластер баз данных MySQL.

 - Используя настройки VPC из предыдущих домашних заданий, добавить дополнительно подсеть private в разных зонах, чтобы обеспечить отказоустойчивость. 
 - Разместить ноды кластера MySQL в разных подсетях.
 - Необходимо предусмотреть репликацию с произвольным временем технического обслуживания.
 - Использовать окружение Prestable, платформу Intel Broadwell с производительностью 50% CPU и размером диска 20 Гб.
 - Задать время начала резервного копирования — 23:59.
 - Включить защиту кластера от непреднамеренного удаления.
 - Создать БД с именем `netology_db`, логином и паролем.

Подготавливаем манифесты:

[mysql_cluster.tf](https://github.com/sash3939/15.4-CloudClusters/blob/main/mysql_cluster.tf)

Предусмотрим следующие особенности:

 - размещение в приватной подсети:
<img width="308" alt="private network" src="https://github.com/user-attachments/assets/0c750c45-6f61-433c-9dfd-58b5250f5f3f" />

- репликацию с произвольным временем технического обслуживания:
<img width="137" alt="replication" src="https://github.com/user-attachments/assets/193f2ae2-3c9d-4a29-9f10-8e24bf49da55" />

-время начала резервного копирования:
<img width="139" alt="start backup" src="https://github.com/user-attachments/assets/2b262f21-7c45-4ab3-9b51-e9895f01bea0" />

-защита от случайного удаления:
<img width="314" alt="protection" src="https://github.com/user-attachments/assets/ad5ed96b-a005-46d8-a47a-5b4ce206e0f0" />

Создадим БД с именем netology_db, логином и паролем:

<img width="383" alt="bd" src="https://github.com/user-attachments/assets/43f1407e-0045-44d5-944a-1ea1d1d0fad8" />

<img width="791" alt="bd1" src="https://github.com/user-attachments/assets/dd7b25d4-19e0-46fb-be02-f0ddb9622569" />

Подключаемся к БД
<img width="587" alt="Connect to db" src="https://github.com/user-attachments/assets/a7909801-c043-46d5-8221-974f69330c56" />

<img width="337" alt="Select" src="https://github.com/user-attachments/assets/d1cfc0a2-3e9a-4398-a0c2-196dcaa9945f" />

<img width="983" alt="connect to db with websql" src="https://github.com/user-attachments/assets/af1baa58-daba-4210-b4a6-d27031c797d3" />

2. Настроить с помощью Terraform кластер Kubernetes.

 - Используя настройки VPC из предыдущих домашних заданий, добавить дополнительно две подсети public в разных зонах, чтобы обеспечить отказоустойчивость.
 - Создать отдельный сервис-аккаунт с необходимыми правами. 
 - Создать региональный мастер Kubernetes с размещением нод в трёх разных подсетях.
 - Добавить возможность шифрования ключом из KMS, созданным в предыдущем домашнем задании.
 - Создать группу узлов, состояющую из трёх машин с автомасштабированием до шести.
 - Подключиться к кластеру с помощью `kubectl`.
 - *Запустить микросервис phpmyadmin и подключиться к ранее созданной БД.
 - *Создать сервис-типы Load Balancer и подключиться к phpmyadmin. Предоставить скриншот с публичным адресом и подключением к БД.


добавим дополнительно две подсети public в разных зонах, чтобы обеспечить отказоустойчивость:
[network.tf](https://github.com/sash3939/15.4-CloudClusters/blob/main/network.tf)

Создадим отдельный сервис-аккаунт с необходимыми правами

Создадим отдельный сервис-аккаунт с необходимыми правами

```
// создание сервисного аккаунта для kubernetes
resource "yandex_iam_service_account" "sa-kube" {
  name = "sa-kube"
  description = "sa-kube"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = "${var.yandex_folder_id}"
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kube.id}"
  depends_on = [yandex_iam_service_account.sa-kube]
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  folder_id = "${var.yandex_folder_id}"
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kube.id}"
  depends_on = [yandex_iam_service_account.sa-kube]
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
 # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = "${var.yandex_folder_id}"
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kube.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
 # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = "${var.yandex_folder_id}"
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kube.id}"
}
```
Создадим региональный мастер Kubernetes с размещением нод в трёх разных подсетях

[yandex_kubernetes_cluster.tf](https://github.com/sash3939/15.4-CloudClusters/blob/main/yandex_kubernetes_cluster.tf)

Добавить возможность шифрования ключом из KMS

```
kms_provider {
    key_id = yandex_kms_symmetric_key.key-a.id
  }
```
Создать группу узлов, состояющую из трёх машин с автомасштабированием до шести

```
scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 1
    }
  }
```

Подключимся к кластеру с помощью kubectl:

```
root@ubuntu-VirtualBox:/home/ubuntu/15.4-CloudClusters# kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
phpmyadmin-deployment-5c4b89b694-4xwfd   1/1     Running   0          23h
root@ubuntu-VirtualBox:/home/ubuntu/15.4-CloudClusters#
root@ubuntu-VirtualBox:/home/ubuntu/15.4-CloudClusters# kubectl config view --minify
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://158.160.40.103
  name: yc-managed-k8s-cat1pi6t6auva3taifuk
contexts:
- context:
    cluster: yc-managed-k8s-cat1pi6t6auva3taifuk
    user: yc-managed-k8s-cat1pi6t6auva3taifuk
  name: yc-netology-k8s
current-context: yc-netology-k8s
kind: Config
preferences: {}
users:
- name: yc-managed-k8s-cat1pi6t6auva3taifuk
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - k8s
      - create-token
      - --profile=kubernetes
      command: /home/aleksturbo/yandex-cloud/bin/yc
      env: null
      interactiveMode: IfAvailable
      provideClusterInfo: false
root@ubuntu-VirtualBox:/home/ubuntu/15.4-CloudClusters# kubectl get all --all-namespaces=true
NAMESPACE     NAME                                         READY   STATUS    RESTARTS   AGE
default       pod/phpmyadmin-deployment-5c4b89b694-4xwfd   1/1     Running   0          23h
kube-system   pod/coredns-67d9cb9656-wg7lq                 1/1     Running   0          2d
kube-system   pod/ip-masq-agent-89cl2                      1/1     Running   0          47h
kube-system   pod/kube-dns-autoscaler-689576d9f4-pt64d     1/1     Running   0          2d
kube-system   pod/kube-proxy-s4586                         1/1     Running   0          47h
kube-system   pod/metrics-server-75d8b888d8-g85d4          2/2     Running   0          47h
kube-system   pod/npd-v0.8.0-zg7rk                         1/1     Running   0          47h
kube-system   pod/yc-disk-csi-node-v2-z4g9h                6/6     Running   0          47h
portainer     pod/portainer-agent-6595fdd67c-nsnzg         1/1     Running   0          46h

NAMESPACE     NAME                               TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                  AGE
default       service/kubernetes                 ClusterIP      10.96.128.1     <none>           443/TCP                  2d
default       service/phpmyadmin-deployment      ClusterIP      10.96.166.8     <none>           80/TCP                   25h
default       service/phpmyadmin-service         LoadBalancer   10.96.190.225   158.160.111.62   80:31253/TCP             36h
kube-system   service/kube-dns                   ClusterIP      10.96.128.2     <none>           53/UDP,53/TCP,9153/TCP   2d
kube-system   service/metrics-server             ClusterIP      10.96.217.151   <none>           443/TCP                  2d
portainer     service/portainer-agent            NodePort       10.96.212.46    <none>           9001:30778/TCP           46h
portainer     service/portainer-agent-headless   ClusterIP      None            <none>           <none>                   46h

NAMESPACE     NAME                                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                                        AGE
kube-system   daemonset.apps/ip-masq-agent                    1         1         1       1            1           beta.kubernetes.io/os=linux,node.kubernetes.io/masq-agent-ds-ready=true              2d
kube-system   daemonset.apps/kube-proxy                       1         1         1       1            1           kubernetes.io/os=linux,node.kubernetes.io/kube-proxy-ds-ready=true                   2d
kube-system   daemonset.apps/npd-v0.8.0                       1         1         1       1            1           beta.kubernetes.io/os=linux,node.kubernetes.io/node-problem-detector-ds-ready=true   2d
kube-system   daemonset.apps/nvidia-device-plugin-daemonset   0         0         0       0            0           beta.kubernetes.io/os=linux,node.kubernetes.io/nvidia-device-plugin-ds-ready=true    2d
kube-system   daemonset.apps/yc-disk-csi-node                 0         0         0       0            0           <none>                                                                               2d
kube-system   daemonset.apps/yc-disk-csi-node-v2              1         1         1       1            1           yandex.cloud/pci-topology=k8s                                                        2d

NAMESPACE     NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
default       deployment.apps/phpmyadmin-deployment   1/1     1            1           23h
kube-system   deployment.apps/coredns                 1/1     1            1           2d
kube-system   deployment.apps/kube-dns-autoscaler     1/1     1            1           2d
kube-system   deployment.apps/metrics-server          1/1     1            1           2d
portainer     deployment.apps/portainer-agent         1/1     1            1           46h

NAMESPACE     NAME                                               DESIRED   CURRENT   READY   AGE
default       replicaset.apps/phpmyadmin-deployment-5c4b89b694   1         1         1       23h
default       replicaset.apps/phpmyadmin-deployment-7d6ffdbf57   0         0         0       23h
kube-system   replicaset.apps/coredns-67d9cb9656                 1         1         1       2d
kube-system   replicaset.apps/kube-dns-autoscaler-689576d9f4     1         1         1       2d
kube-system   replicaset.apps/metrics-server-64d75c78c6          0         0         0       2d
kube-system   replicaset.apps/metrics-server-75d8b888d8          1         1         1       47h
portainer     replicaset.apps/portainer-agent-6595fdd67c         1         1         1       46h
```

<img width="533" alt="not work kuber cluster" src="https://github.com/user-attachments/assets/2319c122-8078-4bdf-be93-fe51a4d1ff3e" />

- Запустим микросервис phpmyadmin и подключиться к ранее созданной БД:
[sa.yaml](https://github.com/sash3939/15.4-CloudClusters/blob/main/sa.yaml)
[phpmyadmin-deployment.yaml](https://github.com/sash3939/15.4-CloudClusters/blob/main/phpmyadmin-deployment.yaml)
[secret-mysql.yaml](https://github.com/sash3939/15.4-CloudClusters/blob/main/secret-mysql.yaml)

```bash
root@ubuntu-VirtualBox:/home/ubuntu/15.4-CloudClusters# kubectl apply -f phpmyadmin-deployment.yaml
deployment.apps/phpmyadmin-deployment created

root@ubuntu-VirtualBox:/home/ubuntu/15.4-CloudClusters# kubectl get deploy -o wide
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                  SELECTOR
phpmyadmin-deployment   1/1     1            1           23h   phpmyadmin   phpmyadmin/phpmyadmin   app=phpmyadmin
```

- Создать сервис-типы Load Balancer и подключиться к phpmyadmin
[service.yml](https://github.com/sash3939/15.4-CloudClusters/blob/main/service.yml)
[ingress.yml](https://github.com/sash3939/15.4-CloudClusters/blob/main/ingress.yml)

```bash
root@ubuntu-VirtualBox:/home/ubuntu/15.4-CloudClusters# kubectl get svc
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
kubernetes              ClusterIP      10.96.128.1     <none>           443/TCP        2d
phpmyadmin-deployment   ClusterIP      10.96.166.8     <none>           80/TCP         25h
phpmyadmin-service      LoadBalancer   10.96.190.225   158.160.111.62   80:31253/TCP   36h
```

Демонстрация работоспособности:

<img width="757" alt="phpmyadmin" src="https://github.com/user-attachments/assets/1109f937-f0c5-4653-8aa0-bb65f71283d5" />


Полезные документы:

- [MySQL cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_cluster).
- [Создание кластера Kubernetes](https://cloud.yandex.ru/docs/managed-kubernetes/operations/kubernetes-cluster/kubernetes-cluster-create)
- [K8S Cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster).
- [K8S node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group).

--- 
## Задание 2*. Вариант с AWS (задание со звёздочкой)

Это необязательное задание. Его выполнение не влияет на получение зачёта по домашней работе.

**Что нужно сделать**

1. Настроить с помощью Terraform кластер EKS в три AZ региона, а также RDS на базе MySQL с поддержкой MultiAZ для репликации и создать два readreplica для работы.
 
 - Создать кластер RDS на базе MySQL.
 - Разместить в Private subnet и обеспечить доступ из public сети c помощью security group.
 - Настроить backup в семь дней и MultiAZ для обеспечения отказоустойчивости.
 - Настроить Read prelica в количестве двух штук на два AZ.

2. Создать кластер EKS на базе EC2.

 - С помощью Terraform установить кластер EKS на трёх EC2-инстансах в VPC в public сети.
 - Обеспечить доступ до БД RDS в private сети.
 - С помощью kubectl установить и запустить контейнер с phpmyadmin (образ взять из docker hub) и проверить подключение к БД RDS.
 - Подключить ELB (на выбор) к приложению, предоставить скрин.

Полезные документы:

- [Модуль EKS](https://learn.hashicorp.com/tutorials/terraform/eks).

### Правила приёма работы

Домашняя работа оформляется в своём Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
