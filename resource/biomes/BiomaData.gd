extends Resource
class_name BiomeData

# Color del cielo
@export var sky_color: Color = Color.SKY_BLUE

# Color de la niebla
@export var fog_color: Color = Color.GRAY

# Intensidad de la niebla
@export_range(0.0, 1.0)
var fog_density: float = 0.2

# Música del bioma
@export var music_track: AudioStream

# Sonido ambiental
@export var ambient_sfx: AudioStream

# Intensidad de las olas
@export_range(0.0, 5.0)
var wave_intensity: float = 1.0

# Obstáculos disponibles en este bioma
@export var obstacle_pool: Array[PackedScene] = []
