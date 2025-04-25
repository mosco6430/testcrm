### 1. ¿Cómo manejarías los secretos y credenciales de forma segura?

Utilizaría Azure Key Vault para almacenar secretos y GitHub Secrets en git hub actions, o a nivel de volumenes claim. El acceso a Key Vault se haría mediante managed identities. En GitHub, almacenaría credenciales cifradas usando `AZURE_CREDENTIALS` por ejemplo.

---

### 2. ¿Cómo revertirías un despliegue si algo rompe producción?

Mantendría versiones anteriores del contenedor en ACR y usaría `az webapp config container set` para apuntar a una versión estable anterior (`rollback`). También implementaría slots para hacer swap rápidamente.

---

### 3. ¿Cómo habilitarías despliegues blue/green o canary?

Usaría Web App Deployment Slots para tener entornos paralelos (`staging`, `production`). También se puede aplicar **Azure Front Door** o **Traffic Manager** para dividir tráfico entre versiones, o paths, . Para canary, dividiría por porcentaje de usuarios o rutas.

---

### 4. ¿Cómo monitorearías y alertarías sobre problemas después del despliegue?

Implementaría Application Insights con alertas configuradas por métricas (fallos, tiempo de respuesta, disponibilidad), dynatrace, grafana con prometeus, y de estrategia con argocd. También integraría con Azure Monitor y Log Analytics para reglas automáticas y notificaciones
