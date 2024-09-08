SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# for training
echo "[1/3] Installing toolkit/training"
cd ${SCRIPT_DIR}/toolkit/training
pip install -r requirements.txt

# for evaluation
# echo "[2/3] Installing toolkit/evaluation"
# cd ${SCRIPT_DIR}/toolkit/evaluation
# pip install -r requirements.txt

# for data-juicer
# echo "[3/3] Installing toolkit/data-juicer"
# cd ${SCRIPT_DIR}/toolkit/data-juicer
# git pull origin main || true
# pip install '.[all]'

echo "Done"
