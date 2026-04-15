import pandas as pd
import csv
import sys
import os

def limpiar(texto):
    if pd.isna(texto) or str(texto).strip() == '':
        return ''
    return str(texto).strip()

def formatear_bullets(texto):
    """Convierte texto con bullets • en líneas separadas para WhatsApp"""
    if not texto:
        return ''
    # Separar por bullet points
    partes = [p.strip() for p in texto.replace('• ', '\n• ').split('\n') if p.strip()]
    return '\n'.join(partes)

def generar_nombre_respuesta(nombre_servicio):
    """Genera el título de la respuesta preestablecida"""
    nombre = nombre_servicio.strip().upper()
    if len(nombre) > 70:
        nombre = nombre[:67] + '...'
    return f"PREP | {nombre}"

def generar_cuerpo_whatsapp(nombre_servicio, preparacion, observacion_extra):
    """Genera el cuerpo del mensaje formateado para WhatsApp"""
    nombre = nombre_servicio.strip().upper()
    
    lineas = []
    lineas.append(f"📋 *{nombre}*")
    
    if preparacion:
        lineas.append("*Preparación:*")
        lineas.append("")
        lineas.append(formatear_bullets(preparacion))
    
    if observacion_extra:
        lineas.append("")
        lineas.append(f"⚠️ *Importante:* {observacion_extra.strip()}")
    
    return '\n'.join(lineas)

def procesar_archivo(ruta_entrada, ruta_salida):
    # Intentar leer el archivo
    try:
        if ruta_entrada.endswith('.csv'):
            df = pd.read_csv(ruta_entrada, sep=None, engine='python', encoding='utf-8-sig')
        else:
            df = pd.read_excel(ruta_entrada)
    except Exception as e:
        print(f"Error leyendo archivo: {e}")
        sys.exit(1)

    print(f"Columnas encontradas: {list(df.columns)}")
    print(f"Total de filas: {len(df)}")

    # Normalizar nombres de columnas
    df.columns = [c.strip().upper().replace(' ', '_') for c in df.columns]
    
    # Mapear columnas esperadas
    col_nombre = next((c for c in df.columns if 'NOMBRE' in c and 'SERV' in c), None) or \
                 next((c for c in df.columns if 'NOMBRE' in c), None)
    col_prep   = next((c for c in df.columns if c == 'PREPARACION'), None) or \
                 next((c for c in df.columns if 'PREP' in c and 'ID' not in c and 'OBS' not in c), None)
    col_obs    = next((c for c in df.columns if 'OBSERVACION_EXTRA' in c), None) or \
                 next((c for c in df.columns if 'EXTRA' in c), None)

    print(f"\nColumnas mapeadas:")
    print(f"  Nombre servicio : {col_nombre}")
    print(f"  Preparación     : {col_prep}")
    print(f"  Observación extra: {col_obs}")

    if not col_nombre or not col_prep:
        print("ERROR: No se encontraron las columnas necesarias.")
        sys.exit(1)

    # Deduplicar por PREPARACION_ID si existe, o por contenido de preparación
    col_prep_id = next((c for c in df.columns if 'PREPARACION_ID' in c or c == 'PREPARACION_ID'), None)
    
    resultados = []
    vistos = {}

    for _, row in df.iterrows():
        nombre   = limpiar(row.get(col_nombre, ''))
        prep     = limpiar(row.get(col_prep, ''))
        obs_extra = limpiar(row.get(col_obs, '')) if col_obs else ''
        prep_id  = limpiar(row.get(col_prep_id, '')) if col_prep_id else prep[:50]

        if not nombre or not prep:
            continue

        # Si ya existe esa preparación, agregar el nombre al título existente
        if prep_id in vistos:
            idx = vistos[prep_id]
            nombre_actual = resultados[idx]['nombre']
            if nombre.upper() not in nombre_actual.upper():
                nombre_corto = nombre[:40] if len(nombre) > 40 else nombre
                nuevo_nombre = nombre_actual.replace('PREP | ', '') + ' / ' + nombre_corto
                if len(nuevo_nombre) > 70:
                    nuevo_nombre = nuevo_nombre[:67] + '...'
                resultados[idx]['nombre'] = f"PREP | {nuevo_nombre}"
        else:
            vistos[prep_id] = len(resultados)
            resultados.append({
                'nombre': generar_nombre_respuesta(nombre),
                'cuerpo': generar_cuerpo_whatsapp(nombre, prep, obs_extra)
            })

    # Escribir CSV de salida compatible con Genesys Cloud
    with open(ruta_salida, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=['Name', 'Body'])
        writer.writeheader()
        for r in resultados:
            writer.writerow({'Name': r['nombre'], 'Body': r['cuerpo']})

    print(f"\n✅ Generadas {len(resultados)} respuestas preestablecidas únicas")
    print(f"📄 Archivo guardado en: {ruta_salida}")
    return len(resultados)

# --- Modo demo con datos de ejemplo ---
if __name__ == '__main__':
    if len(sys.argv) >= 3:
        procesar_archivo(sys.argv[1], sys.argv[2])
    else:
        # Generar demo con los datos de ejemplo del usuario
        datos_demo = [
            {
                'ID': 51, 'COD_INTERNO': 138, 'PREPARACION_ID': 60,
                'NOMBRE SERVICIO': 'DENSITOMETRIA OSEA',
                'MODALIDAD': 'Densitometria',
                'PREPARACION': '• Suspender calcio y vitamina D, 2 días antes del estudio.\n• No haberse realizado estudios con medio de contraste oral 8 días antes del examen',
                'OBSERVACION_PREPARACION': '', 'OBSERVACION_EXTRA': '', 'DESCRIPCION': ''
            },
            {
                'ID': 822, 'COD_INTERNO': 6264, 'PREPARACION_ID': 60,
                'NOMBRE SERVICIO': 'OSTEODENSITOMETRIA POR ABSORCION DUAL DE RAYOS X',
                'MODALIDAD': 'Densitometria',
                'PREPARACION': '• Suspender calcio y vitamina D, 2 días antes del estudio.\n• No haberse realizado estudios con medio de contraste oral 8 días antes del examen',
                'OBSERVACION_PREPARACION': '', 'OBSERVACION_EXTRA': '', 'DESCRIPCION': ''
            },
            {
                'ID': 100, 'COD_INTERNO': 200, 'PREPARACION_ID': 75,
                'NOMBRE SERVICIO': 'ECOGRAFIA ABDOMINAL',
                'MODALIDAD': 'Ecografia',
                'PREPARACION': '• Ayuno de 6 horas antes del examen.\n• No consumir alimentos flatulentos el día anterior.',
                'OBSERVACION_PREPARACION': '', 'OBSERVACION_EXTRA': 'Traer exámenes previos si los tiene.', 'DESCRIPCION': ''
            },
        ]
        df_demo = pd.DataFrame(datos_demo)
        df_demo.to_excel('/home/claude/demo_input.xlsx', index=False)
        procesar_archivo('/home/claude/demo_input.xlsx', '/home/claude/demo_output.csv')
        
        # Mostrar preview
        with open('/home/claude/demo_output.csv', 'r', encoding='utf-8-sig') as f:
            print("\n--- PREVIEW DEL ARCHIVO GENERADO ---")
            print(f.read())