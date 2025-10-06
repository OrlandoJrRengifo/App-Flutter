# App-Flutter

**Autores:** Camilo Navarro y Orlando Rengifo  
**Tecnologías:** Flutter + GetX + Clean Architecture + Roble (servicios de autenticación y almacenamiento)

---

## 🧩 Descripción del Proyecto

Aplicación móvil desarrollada en Flutter que permite a los estudiantes **evaluar el desempeño y compromiso de sus compañeros** en actividades colaborativas de curso.  
Está pensada para apoyar al docente en la gestión de cursos, grupos y evaluaciones entre pares.

### ✨ Características principales

- **Gestión de cursos:**  
  - Los usuarios autenticados pueden crear hasta 3 cursos.  
  - El creador del curso se convierte en su profesor.  
  - Los profesores pueden invitar estudiantes mediante un sistema de invitaciones privadas o verificadas.

- **Organización por grupos:**  
  - Creación de categorías con distintos métodos de agrupamiento (aleatorio, autoasignado o manual).  
  - Posibilidad de mover estudiantes entre grupos.

- **Actividades y evaluaciones:**  
  - Cada categoría puede tener múltiples actividades.  
  - Las actividades pueden incluir una **evaluación entre pares** (sin autoevaluación).  
  - Evaluaciones configurables como **públicas o privadas**.  
  - Resultados visibles por actividad, grupo o estudiante.

- **Criterios de evaluación:**  
  - Puntualidad  
  - Aportes  
  - Compromiso  
  - Actitud  

- **Arquitectura limpia (Clean Architecture):**  
  - Separación de capas: *data, domain, presentation*  
  - Uso de **GetX** para gestión de estado, navegación y dependencias.  
  - Integración con **Roble** para autenticación y almacenamiento.

---

## ⚙️ Instalación y Ejecución

A continuación los pasos para clonar y ejecutar el proyecto:

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/OrlandoJrRengifo/App-Flutter
   cd App-Flutter
  
2. **Instalar dependencias**
   ```bash
   flutter pub get

