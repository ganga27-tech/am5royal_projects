// ============================================================================
// AM5 ROYAL • Formatters & Presentation Utilities
// ============================================================================

export function formatCurrency(amount: number | null | undefined): string {
  if (amount === null || amount === undefined || isNaN(amount)) return '₹0';
  return `₹${amount.toLocaleString('en-IN', {
    maximumFractionDigits: 2,
    minimumFractionDigits: 0,
  })}`;
}

export function formatDate(dateString: string | null | undefined): string {
  if (!dateString) return '—';
  try {
    const d = new Date(dateString);
    if (isNaN(d.getTime())) return dateString;
    return d.toLocaleDateString('en-IN', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    });
  } catch {
    return dateString;
  }
}

export function formatTime(timeString: string | null | undefined): string {
  if (!timeString) return '—';
  return timeString.length > 5 ? timeString.slice(0, 5) : timeString;
}

export function getStatusBadgeClass(status: string | null | undefined): string {
  if (!status) return 'badge-registration';
  const s = status.toLowerCase().replace(/[\s_]+/g, '-');
  switch (s) {
    case 'active':
    case 'activated':
    case 'account-activated':
      return 'badge-active';
    case 'temporary-active':
    case 'temp-active':
      return 'badge-temporary-active';
    case 'slots-done':
    case 'slots':
      return 'badge-slots-done';
    case 'services-added':
    case 'services':
      return 'badge-services-added';
    case 'business-registration':
    case 'business-reg':
      return 'badge-business-registration';
    case 'payment':
    case 'payment-completed':
      return 'badge-payment';
    case 'rejected':
      return 'badge-rejected';
    default:
      return 'badge-registration';
  }
}

export function getStepIndex(status: string | null | undefined): number {
  if (!status) return 0;
  const s = status.toLowerCase().trim();
  switch (s) {
    case 'services':
    case 'services added':
    case 'services_added':
      return 0;
    case 'slots':
    case 'slots done':
    case 'slots_done':
      return 1;
    case 'registration':
      return 2;
    case 'business registration':
    case 'business reg':
    case 'business_registration':
      return 3;
    case 'payment':
    case 'payment completed':
    case 'payment_completed':
    case 'payment done':
      return 4;
    case 'temporary active':
    case 'temporary_active':
    case 'temp active':
    case 'temp_active':
      return 5;
    case 'active':
    case 'activated':
    case 'account activated':
    case 'account_activated':
      return 6;
    default:
      return 0;
  }
}
