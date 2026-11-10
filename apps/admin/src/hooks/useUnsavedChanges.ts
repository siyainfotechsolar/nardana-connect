import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

/**
 * Hook to safeguard form data against accidental browser navigation or page closing.
 */
export function useUnsavedChanges(isDirty: boolean) {
  const navigate = useNavigate();

  useEffect(() => {
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      if (isDirty) {
        e.preventDefault();
        e.returnValue = '';
      }
    };

    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => window.removeEventListener('beforeunload', handleBeforeUnload);
  }, [isDirty]);

  /**
   * Prompts user before discarding form changes and navigating away.
   */
  const handleSafeLeave = (targetRoute: string) => {
    if (isDirty) {
      const confirmed = window.confirm(
        'तुम्ही भरलेली माहिती अजून सेव्ह झालेली नाही. मागे गेल्यास ही माहिती नष्ट होऊ शकते. तुम्हाला खरंच मागे जायचे आहे का?'
      );
      if (!confirmed) return;
    }
    navigate(targetRoute);
  };

  return { handleSafeLeave };
}

