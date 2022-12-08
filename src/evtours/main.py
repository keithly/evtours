import os
from datetime import datetime, date

import cattrs
import httpx
import ujson
from fastapi import FastAPI, Query
from mangum import Mangum

from evtours.models import EvStation

API_KEY = os.environ.get("NREL_API_KEY")
nearest_api = "https://developer.nrel.gov/api/alt-fuel-stations/v1/nearest.json"

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/nearest-ten/")
async def nearest_ten(latitude: float = Query(ge=-90, le=90),
                      longitude: float = Query(ge=-180, le=180)):
    async with httpx.AsyncClient() as client:
        r = await client.get(
            f"{nearest_api}?api_key={API_KEY}&latitude={latitude}&longitude={longitude}&fuel_type=ELEC&limit=10")

    data = ujson.loads(r.text)

    converter = cattrs.Converter()
    converter.register_structure_hook(date, lambda v, _: datetime.fromisoformat(v))
    converter.register_structure_hook(datetime, lambda v, _: datetime.strptime(v, "%Y-%m-%dT%H:%M:%SZ"))

    stations = converter.structure(data["fuel_stations"], list[EvStation])
    distances = [s.distance_km for s in stations]

    return distances


handler = Mangum(app, lifespan="off")
