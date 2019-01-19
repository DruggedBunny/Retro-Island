
Class MarkerBehaviour Extends Behaviour

	Const MARKER_HEIGHT:Float = 10.0

	Global MarkerSprite:Sprite
	
	Field time_created:Int
	
	Function Create (parent:Entity)
	
		If Not MarkerSprite
			
			MarkerSprite			= New Sprite ()
			MarkerSprite.Visible	= False
			MarkerSprite.Scale		= New Vec3f (2.0, MARKER_HEIGHT, 1.0)
			
		Endif
		
		New MarkerBehaviour (MarkerSprite.Copy (parent))
	
	End

	Method New (entity:Entity)
	
		Super.New (entity)
		AddInstance ()
		
		' Slight change here: entities without components do not
		' have an OnStart method!
		
		entity.Parent	= Null
		entity.Visible	= True
		
		entity.Move (0, MARKER_HEIGHT * 0.5, 0)
		
		time_created	= Millisecs ()

	End
	
	Method OnUpdate (elapsed:Float) Override
	
		If Millisecs () - time_created > 1000
			Entity.Destroy ()
		Endif
		
	End
	
End
