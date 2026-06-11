using Microsoft.Extensions.Options;

namespace Cignium.Hosting {
    public class SlotActivatedStartupSettings
    {
        public bool isInWarmupSlot = false;
    }

    public class SlotActivatedStartup {
        private readonly IEnumerable<ISlotActivatedAction> _actions;
        private readonly object _lock = new object();
        private readonly CancellationTokenSource _tokenSource;
        

        public SlotActivatedStartup(IEnumerable<ISlotActivatedAction> actions, IOptions<SlotActivatedStartupSettings >isInWarmupSlot) {
            _actions = actions;
            _tokenSource = new CancellationTokenSource();
            IsInWarmupSlot = isInWarmupSlot.Value;
        }

        public bool IsStarted { get; private set; }
        public SlotActivatedStartupSettings IsInWarmupSlot { get; }

        public void Stop() {
            try {
                _tokenSource.Cancel();
            }
            catch (Exception e) {
            }
        }

        public void NonWarmupRequestDetected() {
            if (IsStarted) {
                return;
            }

            if (_tokenSource == null) {
                throw new InvalidOperationException("The bootstrapper hasn't been initialized");
            }

            if (IsInWarmupSlot.isInWarmupSlot) {
                return;
            }

            lock (_lock) {
                if (IsStarted) {
                    return;
                }

                Start();

                IsStarted = true;
            }
        }

        private void Start() {
            foreach (var action in _actions) {
                action.Execute(_tokenSource.Token);
            }
        }
    }
}