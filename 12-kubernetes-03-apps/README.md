# Домашнее задание к занятию «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
2. После запуска увеличить количество реплик работающего приложения до 2.
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.

------

### Правила приема работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md.

------

# Ответ

- Проведём установку MicroK8S из прошлого задания

    ```
    apt-get install ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose

    apt update
    apt install snapd
    snap install microk8s --classic
    usermod -a -G microk8s $USER
    chown -f -R $USER ~/.kube
    microk8s enable dashboard

    apt-get install -y ca-certificates curl
    curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install kubectl

    kubectl get nodes

    NAME            STATUS   ROLES    AGE    VERSION
    12-kubernetes   Ready    <none>   6d5h   v1.26.3

    microk8s kubectl get pod -A

    NAMESPACE     NAME                                        READY   STATUS    RESTARTS        AGE
    kube-system   kubernetes-dashboard-dc96f9fc-rdnrv         1/1     Running   2 (6h58m ago)   6d5h
    kube-system   dashboard-metrics-scraper-7bc864c59-24q6w   1/1     Running   2 (6h58m ago)   6d5h
    kube-system   metrics-server-6f754f88d-4dgc4              1/1     Running   2 (6h58m ago)   6d5h
    kube-system   calico-node-hvv7c                           1/1     Running   0               6h42m
    kube-system   calico-kube-controllers-64969df687-zzjvs    1/1     Running   0               6h42m
    ```

## Задание 1.

### 1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.

- Создадим файл `deployment-1.yml` с развёртыванием двух контейнеров с настройками по умолчанию.

    ```
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: deployment-1
      name: deployment-1
      namespace: default
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: deployment-1
      template:
        metadata:
          labels:
            app: deployment-1
        spec:
          containers:
            - name: nginx
              image: nginx:latest
              ports:
                - name: http
                  containerPort: 80
                  protocol: TCP
            - name: multitool
              image: wbitt/network-multitool
              ports:
                - name: http-8080
                  containerPort: 8080
                  protocol: TCP
    ```

    ![deployment-1.yml](deployment-1.yml)

- Запускаем развёртывание командой `kubectl create -f deployment-1.yml`

- Проверяем состояние подов командой `kubectl get pods` и `kubectl get deployment`
    ```
    kubectl get pods
    NAME                            READY   STATUS   RESTARTS      AGE
    deployment-1-767d5bff87-9kwbl   1/2     Error    1 (19s ago)   39s
    ...
    kubectl get pods
    NAME                            READY   STATUS             RESTARTS      AGE
    deployment-1-767d5bff87-9kwbl   1/2     CrashLoopBackOff   3 (40s ago)   119s
    ...
    kubectl get deployment
    NAME           READY   UP-TO-DATE   AVAILABLE   AGE
    deployment-1   0/1     1            0           7m12s
    ```

    ![](12-03-01.png)

- Проверим логи пода командой `kubectl logs`
    ```
    kubectl logs --tail=10 --all-containers=true --prefix=true deployment-1-767d5bff87-9kwbl

    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: using the "epoll" event method
    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: nginx/1.23.4
    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6)
    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: OS: Linux 5.15.0-67-generic
    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 65536:65536
    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: start worker processes
    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: start worker process 29
    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: start worker process 30
    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: start worker process 31
    [pod/deployment-1-767d5bff87-9kwbl/nginx] 2023/04/15 10:15:19 [notice] 1#1: start worker process 32
    [pod/deployment-1-767d5bff87-9kwbl/multitool] 2023/04/15 10:21:36 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address in use)
    [pod/deployment-1-767d5bff87-9kwbl/multitool] nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address in use)
    [pod/deployment-1-767d5bff87-9kwbl/multitool] 2023/04/15 10:21:36 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address in use)
    [pod/deployment-1-767d5bff87-9kwbl/multitool] nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address in use)
    [pod/deployment-1-767d5bff87-9kwbl/multitool] 2023/04/15 10:21:36 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address in use)
    [pod/deployment-1-767d5bff87-9kwbl/multitool] nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address in use)
    [pod/deployment-1-767d5bff87-9kwbl/multitool] 2023/04/15 10:21:36 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address in use)
    [pod/deployment-1-767d5bff87-9kwbl/multitool] nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address in use)
    [pod/deployment-1-767d5bff87-9kwbl/multitool] 2023/04/15 10:21:36 [emerg] 1#1: still could not bind()
    [pod/deployment-1-767d5bff87-9kwbl/multitool] nginx: [emerg] still could not bind()
    ```

    Делаем вывод об ошибке `bind() to 0.0.0.0:80 failed (98: Address in use)`, что контейнер `multitool` не может подключиться к порту `80`. Следуя [описанию на сайте Multitool](https://github.com/wbitt/Network-MultiTool#configurable-http-and-https-ports) поменяем порты через переменные окружения в манифесте.

- Выключим неработающий манифест командой `kubectl delete -f deployment-1.yml`

- Создадим файл `deployment-2.yml` с развёртыванием двух контейнеров с переменными окружения.

    ```
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: deployment-2
      name: deployment-2
      namespace: default
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: deployment-2
      template:
        metadata:
          labels:
            app: deployment-2
        spec:
          containers:
            - name: nginx
              image: nginx:latest
              ports:
                - name: http
                  containerPort: 80
                  protocol: TCP
            - name: multitool
              image: wbitt/network-multitool
              ports:
                - name: http-8080
                  containerPort: 8080
                  protocol: TCP
              env:
                - name: HTTP_PORT
                  value: "8080"
                - name: HTTPS_PORT
                  value: "11443"
    ```

    ![deployment-2.yml](deployment-2.yml)

- Запускаем развёртывание командой `kubectl create -f deployment-2.yml`

- Проверяем состояние подов командой `kubectl get pods` и `kubectl get deployment`

    ![](12-03-02.png)

- Проверим логи развёртывания пода 

    ```
    kubectl logs --tail=10 --all-containers=true --prefix=true deployment-2-7d876659d7-2hwh4
    ...
    [pod/deployment-2-7d876659d7-2hwh4/multitool] WBITT Network MultiTool (with NGINX) - deployment-2-7d876659d7-2hwh4 - 10.1.2.89 - HTTP: 8080 , HTTPS: 11443 . (Formerly praqma/network-multitool)
    [pod/deployment-2-7d876659d7-2hwh4/multitool] Replacing default HTTP port (80) with the value specified by the user - (HTTP_PORT: 8080).
    [pod/deployment-2-7d876659d7-2hwh4/multitool] Replacing default HTTPS port (443) with the value specified by the user - (HTTPS_PORT: 11443).
    ```


### 2. После запуска увеличить количество реплик работающего приложения до 2.

- Изменим количество реплик до двух в файле `deployment-3.yml`.

    ```
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: deployment-2
      name: deployment-2
      namespace: default
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: deployment-2
      template:
        metadata:
          labels:
            app: deployment-2
        spec:
          containers:
            - name: nginx
              image: nginx:latest
              ports:
                - name: http
                  containerPort: 80
                  protocol: TCP
            - name: multitool
              image: wbitt/network-multitool
              ports:
                - name: http-8080
                  containerPort: 8080
                  protocol: TCP
              env:
                - name: HTTP_PORT
                  value: "8080"
                - name: HTTPS_PORT
                  value: "11443"
    ```

    ![deployment-3.yml](deployment-3.yml)

- Запускаем развёртывание командой `kubectl apply -f deployment-3.yml`


### 3. Продемонстрировать количество подов до и после масштабирования.

- Проверяем количество подов до увеличения реплик командой `kubectl get pods`, `kubectl get deployment` и `kubectl get replicaset`

    ```
    kubectl get pods

    NAME                            READY   STATUS    RESTARTS   AGE
    deployment-2-7d876659d7-2hwh4   2/2     Running   0          4m34s
    ```

    ```
    kubectl get deployment

    NAME           READY   UP-TO-DATE   AVAILABLE   AGE
    deployment-2   1/1     1            1           7m53s
    ```

    ```
    kubectl get replicaset
    NAME                      DESIRED   CURRENT   READY   AGE
    deployment-2-7d876659d7   1         1         1       10m
    ```


- Проверяем количество подов после увеличения реплик командой `kubectl get pods`, `kubectl get deployment` и `kubectl get replicaset`

    ```
    kubectl get pods

    NAME                            READY   STATUS    RESTARTS   AGE
    deployment-2-7d876659d7-2hwh4   2/2     Running   0          31m
    deployment-2-7d876659d7-qtxwn   2/2     Running   0          51s
    ```

    ```
    kubectl get deployment

    NAME           READY   UP-TO-DATE   AVAILABLE   AGE
    deployment-2   2/2     2            2           16m
    ```

    ```
    kubectl get replicaset

    NAME                      DESIRED   CURRENT   READY   AGE
    deployment-2-7d876659d7   2         2         2       17m
    ```

    ```
    kubectl get events

    ...
    15s         Normal    ScalingReplicaSet   deployment/deployment-2              Scaled up replica set deployment-2-7d876659d7 to 2 from 1
    15s         Normal    SuccessfulCreate    replicaset/deployment-2-7d876659d7   Created pod: deployment-2-7d876659d7-qtxwn
    14s         Normal    Scheduled           pod/deployment-2-7d876659d7-qtxwn    Successfully assigned default/deployment-2-7d876659d7-qtxwn to 12-kubernetes
    14s         Normal    Pulling             pod/deployment-2-7d876659d7-qtxwn    Pulling image "nginx:latest"
    13s         Normal    Pulled              pod/deployment-2-7d876659d7-qtxwn    Successfully pulled image "nginx:latest" in 1.057298022s (1.057302206s including waiting)
    13s         Normal    Created             pod/deployment-2-7d876659d7-qtxwn    Created container nginx
    13s         Normal    Started             pod/deployment-2-7d876659d7-qtxwn    Started container nginx
    13s         Normal    Pulling             pod/deployment-2-7d876659d7-qtxwn    Pulling image "wbitt/network-multitool"
    12s         Normal    Pulled              pod/deployment-2-7d876659d7-qtxwn    Successfully pulled image "wbitt/network-multitool" in 942.832226ms (942.849626ms including waiting)
    12s         Normal    Created             pod/deployment-2-7d876659d7-qtxwn    Created container multitool
    12s         Normal    Started             pod/deployment-2-7d876659d7-qtxwn    Started container multitool
    ```

    ![](12-03-03.png)

### 4. Создать Service, который обеспечит доступ до реплик приложений из п.1.

- Создадим файл `service-1.yml` с конфигурацией сервиса

    ```
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: service-1
    spec:
      selector:
        app: deployment-2
      ports:
        - name: nginx-http
          port: 80
          protocol: TCP
          targetPort: 80
        - name: multitool-http
          port: 8080
          protocol: TCP
          targetPort: 8080
        - name: multitool-https
          port: 11443
          protocol: TCP
          targetPort: 11443
    ```

    ![service-1.yml](service-1.yml)

- Запускаем развёртывание командой `kubectl apply -f service-1.yml`

- Проверяем состояние сервисов командой `kubectl get service`

    ```
    kubectl get service

    NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                     AGE
    kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP                     20d
    service-1    ClusterIP   10.152.183.172   <none>        80/TCP,8080/TCP,11443/TCP   8s
    ```

    ![](12-03-04.png)

- Проверим проброс портов до сервиса запустив последовательно команды:

    - `kubectl port-forward service/service-1 :80`
    - `curl --silent -i 127.0.0.1:44189 | grep Server`
    - `kubectl port-forward service/service-1 :8080`
    - `curl --silent -i 127.0.0.1:43481 | grep Server`

    ![](12-03-05.png)


### 5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

- Создадим файл `pod-1.yml` с конфигурацией пода

    ```
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: pod-1
      labels:
        app: pod-1
    spec:
      containers:
        - name: multitool
          image: wbitt/network-multitool
          ports:
            - name: http-1080
              containerPort: 1080
              protocol: TCP
          env:
            - name: HTTP_PORT
              value: "1080"
            - name: HTTPS_PORT
              value: "10443"
    ```

    ![pod-1.yml](pod-1.yml)

- Запускаем развёртывание командой `kubectl apply -f pod-1.yml`

- Проверяем состояние подов командой `kubectl get pod -o wide`

    ```
    kubectl get pod -o wide

    NAME                            READY   STATUS    RESTARTS   AGE   IP          NODE            NOMINATED NODE   READINESS GATES
    deployment-2-7d876659d7-2hwh4   2/2     Running   0          89m   10.1.2.89   12-kubernetes   <none>           <none>
    deployment-2-7d876659d7-qtxwn   2/2     Running   0          59m   10.1.2.91   12-kubernetes   <none>           <none>
    pod-1                           1/1     Running   0          7s    10.1.2.92   12-kubernetes   <none>           <none>
    ```

- Запускаем curl из пода командой `kubectl exec`

    ```
    kubectl exec pod-1 -- curl --silent -i 10.1.2.89:80 | grep Server
    kubectl exec pod-1 -- curl --silent -i 10.1.2.89:8080 | grep Server
    ```

    ![](12-03-06.png)


- Удалим развернутые ресуры

    ```
    kubectl delete -f deployment-3.yml -f service-1.yml -f pod-1.yml
    ```


## Задание 2.

### 1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.

- Включим поддержку DNS в microk8s командой `microk8s enable dns`

- Проверим отсутствие подов и сервисов командами `kubectl get pod` и `kubectl get service`

    ```
    kubectl get pod

    No resources found in default namespace.
    ```
    ```
    ubectl get service

    NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
    kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   20d
    ```

### 2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.

- Создадим файл `deployment-4.yml` с конфигурацией развёртывания

    ```
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: deployment-4
      name: deployment-4
      namespace: default
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: deployment-4
      template:
        metadata:
          labels:
            app: deployment-4
        spec:
          containers:
            - name: nginx
              image: nginx:latest
              ports:
                - name: http
                  containerPort: 80
                  protocol: TCP
          initContainers:
            - name: busybox
              image: busybox:latest
              command: ['sh', '-c', 'until nslookup service-2.default.svc.cluster.local; do echo Waiting for service-2!; sleep 5; done;']
    ```

    ![deployment-4.yml](deployment-4.yml)

- Запускаем развёртывание командой `kubectl apply -f deployment-4.yml`

- Проверяем состояние подов до создания сервиса командой `kubectl get pod -o wide`

    ```
    kubectl get pod -o wide
    NAME                           READY   STATUS     RESTARTS   AGE   IP          NODE            NOMINATED NODE   READINESS GATES
    deployment-4-99b9c99d6-wvp4b   0/1     Init:0/1   0          34s   10.1.2.94   12-kubernetes   <none>           <none>
    ```

    ![](12-03-08.png)

- Проверим логи пода командой `kubectl logs`
    ```
    kubectl logs --tail=10 --all-containers=true --prefix=true deployment-4-99b9c99d6-wvp4b

    Error from server (BadRequest): container "nginx" in pod "deployment-4-99b9c99d6-wvp4b" is waiting to start: PodInitializing
    ```

    ![](12-03-07.png)

- Проверим рзарешение имени сервиса командой

    ```
    kubectl exec deployment-4-99b9c99d6-wvp4b -c busybox -- nslookup service-2.default.svc.cluster.local

    Server:         10.152.183.10
    Address:        10.152.183.10:53
    ** server can't find service-2.default.svc.cluster.local: NXDOMAIN
    command terminated with exit code 1
    ```

### 3. Создать и запустить Service. Убедиться, что Init запустился.

- Создадим файл `service-2.yml` с конфигурацией сервиса

    ```
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: service-2
    spec:
      selector:
        app: deployment-4
      ports:
        - name: nginx-http
          port: 80
          protocol: TCP
          targetPort: 80
    ```

    ![service-2.yml](service-2.yml)

- Запускаем развёртывание командой `kubectl apply -f service-2.yml`

- Проверяем состояние подов до создания сервиса командой `kubectl get pod -o wide`

    ```
    kubectl get pod -o wide

    NAME                           READY   STATUS    RESTARTS   AGE   IP          NODE            NOMINATED NODE   READINESS GATES
    deployment-4-99b9c99d6-wvp4b   1/1     Running   0          17m   10.1.2.94   12-kubernetes   <none>           <none>
    ```

- Проверим список сервисов командой `kubectl get service`

    ```
    kubectl get service

    NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
    kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP   20d
    service-2    ClusterIP   10.152.183.184   <none>        80/TCP    56s
    ```


### 4. Продемонстрировать состояние пода до и после запуска сервиса.


- Проверяем состояние подов после создания сервиса командой `kubectl get pod -o wide`

    ![](12-03-09.png)

    Увидим что под запустился


- Удалим развернутые ресуры

    ```
    kubectl delete -f deployment-4.yml -f service-2.yml
    ```





