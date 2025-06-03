# Задание 5. Управление трафиком внутри кластера Kubernetes

### Цель
Развернуть четыре pod'а (сервиса) с образом nginx в одном namespace и изолировать сетевой трафик между ними с помощью сетевых политик (NetworkPolicy), разрешив трафик только между связанными компонентами: UI ↔ API.


### Структура сервисов
Каждому pod'у назначается метка (label) в соответствии с его ролью:

| Имя Pod                  | Label (role)         |
| ------------------------ | -------------------- |
| `front-end-app`          | `front-end`          |
| `back-end-api-app`       | `back-end-api`       |
| `admin-front-end-app`    | `admin-front-end`    |
| `admin-back-end-api-app` | `admin-back-end-api` |

---

## Подготовка среды

**1. Запуск кластера с CNI**
```
minikube start --network-plugin=cni --cni=calico
```

**2. Создание namespace**
```
kubectl create namespace development
```

**3.Развёртывание сервисов**
```
kubectl run front-end-app --image=nginx --labels=role=front-end -n development --expose --port=80
kubectl run back-end-api-app --image=nginx --labels=role=back-end-api -n development --expose --port=80
kubectl run admin-front-end-app --image=nginx --labels=role=admin-front-end -n development --expose --port=80
kubectl run admin-back-end-api-app --image=nginx --labels=role=admin-back-end-api -n development --expose --port=80
```

**Применение сетевых политик**
```
kubectl apply -f non-admin-api-allow.yaml
```

---
## Проверка

**Проверка связи из front-end-app**
```
kubectl exec -it front-end-app -n development -- sh
```

Есть доступ к back-end-api-app:
```
curl -m 2 http://back-end-api-app
```

Нет доступа к admin-back-end-api-app
```
curl -m 2 http://admin-back-end-api-app
# curl: (28) Connection timed out after 2000 milliseconds
```

**Проверка связи из admin-front-end-app**
```
kubectl exec -it admin-front-end-app -n development -- sh
```

Есть доступ к admin-back-end-api-app
```
curl -m 2 http://admin-back-end-api-app
```

Нет доступа к back-end-api-app
```
curl -m 2 http://back-end-api-app
# curl: (28) Connection timed out after 2001 milliseconds
```

---

Сетевые политики корректно разграничивают трафик между сервисами внутри одного namespace:

- `front-end-app может` взаимодействовать только с `back-end-api-app`.
- `admin-front-end-app` может взаимодействовать только с `admin-back-end-api-app`.

Все остальные соединения между pod'ами внутри **development** namespace заблокированы.
