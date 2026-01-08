import os
import requests
import pickle
import numpy as np
import pandas as pd  # <--- ADDED THIS
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app) 

# --- 1. CONFIGURATION ---
API_KEY = "d3d00b5e9a92980566cf6e1f59137e1b" 
BASE_URL = "http://api.openweathermap.org/data/2.5/weather"

# --- 2. LOAD MODEL ---
model = None
try:
    with open('model.pkl', 'rb') as f:
        model = pickle.load(f)
    print("✅ ML Model loaded successfully!")
except FileNotFoundError:
    print("⚠️ 'model.pkl' not found.")

@app.route('/predict', methods=['POST'])
def predict_flood():
    try:
        # A. Receive City
        data = request.json
        city = data.get('city')
        if not city: return jsonify({"error": "City required"}), 400

        # --- DEBUG BACKDOOR ---
        if city.lower() == "atlantis":
            return jsonify({
                "risk": "High", "weather": "Kiamat, 20°C", "suggested_city": "Atlantis",
                "before_flood": ["Lari"], "during_flood": ["Berenang"], "after_flood": ["Keringkan baju"]
            })

        # B. Get Real-Time Weather
        params = {'q': city, 'appid': API_KEY, 'units': 'metric'}
        r = requests.get(BASE_URL, params=params)
        
        if r.status_code != 200:
            return jsonify({"error": "City not found"}), 404
            
        weather_data = r.json()
        
        # C. Extract Features
        # 1. Rain
        rain_1h = 0.0
        if 'rain' in weather_data:
            rain_1h = weather_data['rain'].get('1h', 0.0)
            
        # 2. Humidity & Wind
        humidity = weather_data['main']['humidity']
        wind_speed = weather_data['wind']['speed']
        
        # UI Metadata
        weather_desc = weather_data['weather'][0]['description']
        temp = weather_data['main']['temp']

        # --- D. LOGIC FIX: DATAFRAME & SCALING ---
        # 1. Estimate Daily Rain (x24) because Model was trained on daily totals
        estimated_daily_rain = rain_1h * 24 
        
        # 2. Fix the "UserWarning": Create a DataFrame with column names
        # IMPORTANT: These names must match your CSV file columns EXACTLY
        features_df = pd.DataFrame(
            [[estimated_daily_rain, humidity, wind_speed]], 
            columns=['RR', 'RH_avg', 'ff_avg']
        )
        
        risk_level = "Low"
        
        # AI PREDICTION
        if model:
            prediction = model.predict(features_df)[0] 
            
            if prediction == 1:
                risk_level = "High"
            else:
                # --- MANUAL OVERRIDE (SENSITIVITY BOOSTER) ---
                # Real-time data is often "calmer" than historical data.
                # We need to be paranoid.
                
                # If rain > 5mm/hr (Heavy Rain) -> HIGH
                if rain_1h > 5.0:
                    risk_level = "High"
                
                # If rain > 0.5mm/hr (Light Rain) AND Humidity is High -> MEDIUM
                elif rain_1h > 0.5 and humidity > 85:
                    risk_level = "Medium"
                
                # If Wind is strong (>20 km/h) AND Raining -> MEDIUM
                elif wind_speed > 5.5 and rain_1h > 0: # 5.5 m/s is approx 20km/h
                    risk_level = "Medium"
                
                else:
                    risk_level = "Low"

        # E. MITIGATION LISTS
        before, during, after = [], [], []
        if risk_level == "High":
            before = ["Matikan listrik utama", "Evakuasi dokumen", "Siapkan Tas Siaga"]
            during = ["EVAKUASI SEGERA", "Hindari tiang listrik", "Hubungi 112"]
            after = ["Cek kerusakan rumah", "Bersihkan lumpur", "Periksa kesehatan"]
        elif risk_level == "Medium":
            before = ["Bersihkan selokan", "Pantau info BMKG", "Simpan barang elektronik"]
            during = ["Kurangi aktivitas luar", "Waspada genangan air", "Siapkan senter"]
            after = ["Bersihkan halaman", "Cek atap bocor", "Keringkan perabotan"]
        else:
            before = ["Jaga kebersihan lingkungan", "Cek atap rumah", "Buang sampah pada tempatnya"]
            during = ["Tetap tenang", "Pantau cuaca", "Hati-hati jalan licin"]
            after = ["Lanjutkan aktivitas", "Jaga kesehatan", "Olahraga rutin"]

        return jsonify({
            "risk": risk_level,
            "weather": f"{weather_desc.title()}, {temp}°C",
            "suggested_city": weather_data['name'],
            "before_flood": before,
            "during_flood": during,
            "after_flood": after
        })

    except Exception as e:
        print("Error:", e)
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)