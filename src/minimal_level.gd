extends Spatial


onready var _player: Player = $Player
onready var _camera_system: LevelCameraSystem = $LevelCameraSystem
onready var _bullet_manager: BulletManager = $BulletManager


func _ready():
	_player.camera_system = _camera_system
	GenUtils.connect_signal_assert_ok(
			_player, "shooting", 
			self, "_on_player_shooting"
	)


func _on_player_shooting(player_weapon: Weapon) -> void:
	_bullet_manager.spawn_bullet(player_weapon, _player)
