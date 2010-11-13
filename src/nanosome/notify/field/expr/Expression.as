package nanosome.notify.field.expr {
	import nanosome.notify.field.NumberField;
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.field.INumberField;
	import nanosome.notify.field.expr.value.IValue;
	import nanosome.notify.field.system.FONT_INFO;

	import flash.system.Capabilities;
	import flash.utils.Dictionary;

	/**
	 * @author mh
	 */
	public class Expression extends Field implements IFieldObserver, INumberField {
		
		public static const ZERO: Expression = new Expression( 0 );
		private static const EMPTY: Object = {};
		
		private var _expr: IValue;
		private var _dpi: Number;
		private var _fields: Object;
		private var _number: Number;
		private var _base: INumberField;
		private var _fieldRegistry: Dictionary;
		private var _fieldTargets: Object;
		private var _changeable: Boolean;
		private var _int: int;

		public function Expression( expression: *, changeable: Boolean = false ) {
			super( expression );
			_changeable = changeable;
		}
		
		override protected function notifyValueChange( oldValue: *, newValue: * ): void {
			
			_expr = PARSER.parse( newValue );
			
			if( _expr && _expr.requiresFontSize ) {
				FONT_INFO.addObserver( this );
			} else {
				FONT_INFO.removeObserver( this );
			}
			
			if( _expr ) {
				if( _expr.requiresDPI ) _dpi = Capabilities.screenDPI;
				updateValue();
			} else {
				_number = NaN;
				_int = NaN;
			}
			
			super.notifyValueChange( oldValue, newValue );
		}
		
		override public function addObserver( observer: IFieldObserver, executeImmediately: Boolean = false,
													weakReference: Boolean = false  ): Boolean {
			var result: Boolean = super.addObserver(observer);
			if( executeImmediately ) {
				observer.onFieldChange( this, null, _number );
			}
			return result;
		}
		
		override public function removeObserver( observer: IFieldObserver ): Boolean {
			if( !_expr.isStatic ) {
				return super.removeObserver(observer);
			} else {
				return false;
			}
		}
		
		public function get requiredFields(): Array {
			return _expr.requiredFields;
		}
		
		public function base( value: * ): Expression {
			var base: INumberField = getNumberField( value );
			if( _expr.requiresBase )
			{
				var old: INumberField = _base;
				_base = base;
				checkObserving( old );
				checkObserving( base );
				updateValue();
			}
			return this;
		}
		
		public function notify( observer: IFieldObserver ): Expression {
			addObserver( observer );
			return this;
		}
		
		private function getNumberField( value: * ): INumberField {
			if( value is INumberField ) {
				return value;
			} else if( value is IField ) {
				return new NumberFieldWrapper( value );
			} else {
				return new NumberField( value );
			}
		}
		
		private function checkObserving( value: INumberField ) : void {
			if( value ) {
				if( hasObservers && ( value == _base || _fieldRegistry[ value ] ) )
					value.addObserver( this );
				else
					value.removeObserver( this );
			}
		}
		
		public function field( fieldName: String, value: * ): Expression {
			removeField( fieldName );
			// Only add the field as important if the expression makes use of it.
			if( _expr.requiredFields && _expr.requiredFields.indexOf( fieldName ) != -1 )
			{
				var target: INumberField = getNumberField( value );
				if( !_fieldTargets ) {
					_fieldRegistry = new Dictionary();
					_fieldTargets = {};
				}
				_fieldTargets[ fieldName ] = target;
				var array: Array = _fieldRegistry[ target ] || ( _fieldRegistry[ target ] = [] );
				if( array.indexOf( fieldName ) == -1 ) {
					array.push( fieldName );
				}
				checkObserving( target );
			}
			return this;
		}
		
		public function fields( fields: Object, clearAll: Boolean = false ): Expression {
			if( clearAll ) {
				clearFields();
			}
			for( var fieldName: String in fields ) {
				field( fieldName, fields[ fieldName ] );
			}
			return this;
		}
		
		public function clearFields(): Expression {
			for( var target: * in _fieldRegistry ) {
				removeTarget( target );
			}
			return this;
		}
		
		public function removeField( fieldName: String ): Expression {
			if( _fieldTargets ) {
				var target: Expression = _fieldTargets[ fieldName ];
				var list: Array = _fieldRegistry[ target ];
				if( list ) {
					var index: int = list.indexOf( fieldName );
					delete _fields[ fieldName ];
					if( index != -1 ) {
						if( list.length == 0 ) {
							delete _fieldRegistry[ target ];
							checkObserving( target );
						} else {
							list.splice( index, 1 );
						}
					}
					updateValue();
				}
			}
			return this;
		}
		
		public function removeTarget( target: INumberField ): Expression {
			var list: Array = _fieldRegistry[ target ];
			if( list ) {
				while( list.length > 0 ) {
					var fieldName: String = list.pop();
					delete _fields[ fieldName ];
					delete _fieldTargets[ fieldName ];
				}
				delete _fieldRegistry[ target ];
				updateValue();
			}
			return this;
		}
		
		private function updateValue(): void {
			if( _expr ) {
				var base: Number = NaN;
				if( _base ) {
					base = _base.asNumber;
				}
				var newValue: Number = _expr.getValue( base, _dpi, FONT_INFO.fontSize, FONT_INFO.xSize, _fields || EMPTY );
				if( newValue != _number ) {
					_number = newValue;
					if( _number == Infinity ) {
						_int = int.MAX_VALUE;
					} else if( _number == -Infinity ) {
						_int = int.MIN_VALUE;
					} else {
						_int = newValue;
					}
					notifyStateChange();
				}
			}
		}
		
		override public function dispose(): void {
			super.dispose();
			clearFields();
			base( null );
		}
		
		public function onFieldChange( field: IField, oldValue: * = null, newValue: * = null ) : void {
			if( _fieldRegistry ) {
				// base might leave a empty registry
				var fields: Array = _fieldRegistry[ field ];
				if( fields ) {
					// base might have no fields!
					var i: int = fields.length;
					while( --i -(-1) ) {
						_fields[ fields[i] ] = newValue;
					}
				}
			}
			updateValue();
		}
		
		public function get asNumber(): Number {
			return _number;
		}
		
		public function get asInt(): int {
			return _int;
		}
		
		override public function get isChangeable(): Boolean {
			return _changeable;
		}
	}
}
