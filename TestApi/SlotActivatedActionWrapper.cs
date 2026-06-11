using System;
using System.Threading;

namespace Cignium.Hosting {
    public class SlotActivatedActionWrapper : ISlotActivatedAction {
        private readonly Action<CancellationToken> _action;

        public SlotActivatedActionWrapper(Action<CancellationToken> action) {
            _action = action;
        }

        public void Execute(CancellationToken token) {
            _action(token);
        }
    }
}