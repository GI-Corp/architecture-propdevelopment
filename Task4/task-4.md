# Задание 4. Защита доступа к кластеру Kubernetes

### Цель
Организовать разграниченный доступ пользователей к кластеру Kubernetes с помощью механизма ролевой модели (RBAC), в соответствии с принципами наименьших привилегий и оргструктурой предприятия.

### Описание
1. Разворачивается кластер Minikube.
2. Создаются пользователи с различными правами доступа.
3. Определяются роли и соответствующие полномочия.
4. Настраиваются Role, ClusterRole, RoleBinding и ClusterRoleBinding.

---

## Таблица ролей и прав доступа
| Роль              | Разрешения (Verbs)                                   | Ресурсы (Resources)                             | Назначение                                  | Группа пользователей                       |
| ----------------- | ---------------------------------------------------- | ----------------------------------------------- | ------------------------------------------- | ------------------------------------------ |
| `secrets-reader`  | `get`, `list`, `watch`                               | `secrets` (в пределах namespace)                | Чтение секретов в ограниченном пространстве | Специалисты по информационной безопасности |
| `cluster-reader`  | `get`, `list`, `watch`                               | `pods`, `services`, `configmaps`, `deployments` | Мониторинг ресурсов кластера                | Разработчики, владельцы продукта           |
| `cluster-manager` | `create`, `delete`, `update`, `get`, `list`, `watch` | `pods`, `services`, `configmaps`, `deployments` | Управление инфраструктурой и ресурсами      | DevOps-инженеры, инженеры эксплуатации     |

---

## Инструкция по запуску

**1. Запуск кластера и подготовка namespace**
```
minikube start
kubectl create namespace development
```

**2. Создание пользователей**
```
./create-users.sh
```

**3. Применение ролей и привязок**
```
kubectl apply -f roles.yaml
kubectl apply -f roles_bindings.yaml
```

**4. Проверка доступов**
```
kubectl auth can-i get secrets --as=secure-operator -n development           # yes
kubectl auth can-i get pods --as=cluster-viewer -n development               # yes
kubectl auth can-i create pods --as=cluster-viewer -n development            # no
kubectl auth can-i get pods --as=cluster-manager -n development              # yes
kubectl auth can-i create pods --as=cluster-manager -n development           # yes
kubectl auth can-i get secrets --as=cluster-manager -n development           # no
```