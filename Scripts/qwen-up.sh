#!/bin/zsh

export OLLAMA_HOST=127.0.0.1:5000
MODEL="qwen2.5-coder:14b"

echo "Levantando $MODEL en el puerto 5000..."

if ! systemctl is-active --quiet ollama; then
    echo "❌ El servicio de Ollama está apagado. Inicializando servicio..."
    sudo systemctl start ollama
    sleep 2
fi

echo "🧠 Cargando modelo en RAM"
curl -s -X POST http://localhost:5000/api/generate -d "{\"model\": \"$MODEL\"}" > /dev/null

# 3. Verificar consumo de RAM
RAM_USAGE=$(free -h | grep Mem | awk '{print $3}')
echo "✅ ¡Modelo cargado y listo para laburar!"
echo "📊 RAM en uso actual: $RAM_USAGE"
echo "🤖 Qwen te está esperando en OpenCode."
