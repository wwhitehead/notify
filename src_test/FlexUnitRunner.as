package {
	import flash.display.Sprite;
	import nanosome.notify.bind.BinderTest;
	import nanosome.notify.bind.TestPath;
	import nanosome.notify.bind.WatchTest;
	import nanosome.notify.connect.DynamicConnectionTest;
	import nanosome.notify.connect.StaticConnectionTest;
	import nanosome.notify.field.FieldTest;
	import nanosome.notify.field.SpriteTest;
	import nanosome.notify.field.expr.ExpressionTest;
	import nanosome.notify.observe.PropertyBroadcasterTest;
	import org.flexunit.internals.TraceListener;
	import org.flexunit.runner.FlexUnitCore;



	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="640", height="480")]

	public class FlexUnitRunner extends Sprite {
		
		
		private var core : FlexUnitCore;

		public function FlexUnitRunner() {
			//Instantiate the core.
			core = new FlexUnitCore();
			
			//Add any listeners. In this case, the TraceListener has been added to display results.
			core.addListener(new TraceListener());
			
			STAGE = stage;
			
			core.run( [
				BinderTest,
				WatchTest,
				FieldTest,
				PropertyBroadcasterTest,
				DynamicConnectionTest,
				StaticConnectionTest,
				ExpressionTest,
				SpriteTest,
				TestPath
			] );
		}
	}
}
