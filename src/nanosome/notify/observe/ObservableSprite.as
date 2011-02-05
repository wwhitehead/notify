//  
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License. 
// 
package nanosome.notify.observe {
	
	
	import nanosome.util.DisposableSprite;
	import nanosome.util.ILockable;
	
	/**
	 * <code>ObservableSprite</code> is a util to easily implement
	 * <code>IPropertyObservable</code> that is based to the Sprite class.
	 * 
	 * <p>The implementation can be handled by simply extending <code>ObservableSprite</code>.
	 * It will be more code that using [Bindable] (as a competing way to achieve that)
	 * but it will be more effient.</p>
	 * 
	 * @example
	 *   <code>
	 *     class MyObservableSprite extends ObservableSprite {
	 *       private var _member: *;
	 *       
	 *       public function set member( member: * ): void {
	 *         if( member != _member ) notifyPropertyChanged( "member", _member, _member = member );
	 *       }
	 *       
	 *       public function get member(): * {
	 *         return _member;
	 *       }
	 *     }
	 *   </code>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see IPropertyObservable
	 */
	public class ObservableSprite
					extends DisposableSprite
					implements IPropertyObservable, ILockable {
		
		// Internal broadcaster used to handle all that heavy lifting
		private const _broadcaster: PropertyBroadcaster = new PropertyBroadcaster();
		
		/**
		 * Constructs the new <code>ObserverableSprite</code>
		 */
		public function ObservableSprite() {
			_broadcaster.target = this;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose(): void {
			super.dispose();
			_broadcaster.dispose();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public final function unlock(): void {
			locked = false;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public final function lock(): void {
			locked = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get locked(): Boolean {
			return _broadcaster.locked;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set locked( locked: Boolean ): void {
			_broadcaster.locked = locked;
		}
		
		/**
		 * @inheritDoc
		 */
		public final function addPropertyObserver( observer: IPropertyObserver, weak: Boolean = false ): Boolean {
			return _broadcaster.add( observer, weak );
		}
		
		/**
		 * @inheritDoc
		 */
		public final function removePropertyObserver( observer: IPropertyObserver ): Boolean {
			return _broadcaster.remove( observer );
		}
		
		/**
		 * Notifies all the observers about a change in object structure.
		 * 
		 * @param name Name of the property that changed
		 * @param oldValue Value that the property had prior to the change
		 * @param newValue Value that the property has now
		 */
		protected function notifyPropertyChange( name: String, oldValue: *, newValue: * ): void {
			_broadcaster.notifyPropertyChange( name, oldValue, newValue );
		}
	}
}
