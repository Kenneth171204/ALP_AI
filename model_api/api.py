import os
import requests
import pickle
import numpy as np
import pandas as pd
from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
from collections import defaultdict

app = Flask(__name__)
CORS(app) 

API_KEY = "d3d00b5e9a92980566cf6e1f59137e1b" 
FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast"

# LOAD MODEL
model = None
try:
    with open('model.pkl', 'rb') as f:
        model = pickle.load(f)
    print("✅ ML Model loaded successfully!")
except FileNotFoundError:
    print("⚠️ 'model.pkl' not found.")

def get_mitigation(risk_level):
    if risk_level == "High":
        return {
            "before": ["Matikan listrik utama", "Evakuasi dokumen", "Siapkan Tas Siaga"],
            "during": ["EVAKUASI SEGERA", "Hindari tiang listrik", "Hubungi 112"],
            "after": ["Cek kerusakan rumah", "Bersihkan lumpur", "Periksa kesehatan"]
        }
    elif risk_level == "Medium":
        return {
            "before": ["Bersihkan selokan", "Pantau info BMKG", "Simpan barang elektronik"],
            "during": ["Kurangi aktivitas luar", "Waspada genangan air", "Siapkan senter"],
            "after": ["Bersihkan halaman", "Cek atap bocor", "Keringkan perabotan"]
        }
    else:
        return {
            "before": ["Jaga kebersihan lingkungan", "Cek atap rumah", "Buang sampah pada tempatnya"],
            "during": ["Tetap tenang", "Pantau cuaca", "Hati-hati jalan licin"],
            "after": ["Lanjutkan aktivitas", "Jaga kesehatan", "Olahraga rutin"]
        }

def calculate_daily_risk(rain_sum, humid_avg, wind_avg):
    # 1. Prepare Dataframe
    features_df = pd.DataFrame(
        [[rain_sum, humid_avg, wind_avg]], 
        columns=['RR', 'RH_avg', 'ff_avg']
    )
    
    risk_level = "Low"
    
    # 2. AI Prediction
    if model:
        prediction = model.predict(features_df)[0] 
        if prediction == 1:
            risk_level = "High"

    # 3. Manual Override (Safety Net)
    if risk_level != "High":
        if rain_sum > 50.0: risk_level = "High" 
        elif rain_sum > 20.0 and humid_avg > 85: risk_level = "Medium"
        elif wind_avg > 5.5 and rain_sum > 5.0: risk_level = "Medium"
    
    return risk_level

@app.route('/predict', methods=['POST'])
def predict_flood():
    try:
        data = request.json
        city = data.get('city')
        if not city: return jsonify({"error": "City required"}), 400

        # --- A. Get 5-Day Data ---
        params = {'q': city, 'appid': API_KEY, 'units': 'metric'}
        r = requests.get(FORECAST_URL, params=params)
        
        if r.status_code != 200:
            return jsonify({"risk": "NotFound", "weather": "Kota tidak ditemukan"}), 404
            
        json_data = r.json()
        city_name = json_data['city']['name']
        
        # --- B. Group Data by Date ---
        daily_groups = defaultdict(lambda: {
            'temps': [], 'humidities': [], 'winds': [], 'rains': [], 'weather_desc': []
        })

        for item in json_data['list']:
            date_key = item['dt_txt'].split(' ')[0] 
            
            daily_groups[date_key]['temps'].append(item['main']['temp'])
            daily_groups[date_key]['humidities'].append(item['main']['humidity'])
            daily_groups[date_key]['winds'].append(item['wind']['speed'])
            daily_groups[date_key]['weather_desc'].append(item['weather'][0]['description'])
            
            rain_val = 0.0
            if 'rain' in item and '3h' in item['rain']:
                rain_val = item['rain']['3h']
            daily_groups[date_key]['rains'].append(rain_val)

        # --- C. Process Each Day ---
        forecast_list = []
        sorted_dates = sorted(daily_groups.keys())[:5] # Limit to 5 days

        for date in sorted_dates:
            d = daily_groups[date]
            
            avg_temp = np.mean(d['temps'])
            avg_humid = np.mean(d['humidities'])
            avg_wind = np.mean(d['winds'])
            total_rain = sum(d['rains'])
            
            most_common_desc = max(set(d['weather_desc']), key=d['weather_desc'].count)

            risk = calculate_daily_risk(total_rain, avg_humid, avg_wind)
            mitigation = get_mitigation(risk)

            date_obj = datetime.strptime(date, '%Y-%m-%d')
            date_display = date_obj.strftime('%a, %d %b') # e.g. "Mon, 01 Jan"

            forecast_list.append({
                "date": date_display,
                "temp": round(avg_temp, 1),
                "risk": risk,
                "weather": most_common_desc.title(),
                "before_flood": mitigation['before'],
                "during_flood": mitigation['during'],
                "after_flood": mitigation['after']
            })

        if not forecast_list: return jsonify({"error": "No data"}), 500

        # Return: Today (index 0) and Forecast (index 1 to 4)
        return jsonify({
            "risk": "OK",
            "city_name": city_name,
            "current": forecast_list[0],
            "forecast": forecast_list[1:] 
        })

    except Exception as e:
        print("Error:", e)
        return jsonify({"risk": "Error", "weather": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)