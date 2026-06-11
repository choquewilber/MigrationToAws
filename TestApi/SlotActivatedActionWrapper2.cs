using System;
using System.Threading;

namespace Cignium.Hosting {
    public class SlotActivatedActionWrapper2 : ISlotActivatedAction {
        private readonly Action<CancellationToken> _action;

        public SlotActivatedActionWrapper2(Action<CancellationToken> action) {
            _action = action;
        }

        public void Execute(CancellationToken token) {
            _action(token);
        }
    }
}