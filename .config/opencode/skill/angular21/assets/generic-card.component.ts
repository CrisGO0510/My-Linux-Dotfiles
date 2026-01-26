// Generic component template with Angular Material and signals using inject()
import { 
  Component, 
  input, 
  output, 
  signal, 
  computed,
  inject,
  ChangeDetectionStrategy 
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

export interface GenericItem {
  id: string;
  title: string;
  description?: string;
  imageUrl?: string;
  active?: boolean;
}

@Component({
  selector: 'app-generic-card',
  standalone: false, // Use module by default
  template: `
    <mat-card class="generic-card" [class.inactive]="!item().active">
      @if (loading()) {
        <div class="loading-overlay">
          <mat-spinner diameter="40"></mat-spinner>
        </div>
      }
      
      @if (item().imageUrl; as imageUrl) {
        <img mat-card-image [src]="imageUrl" [alt]="item().title">
      }
      
      <mat-card-header>
        <mat-card-title>{{ item().title }}</mat-card-title>
        @if (item().description; as description) {
          <mat-card-subtitle>{{ description }}</mat-card-subtitle>
        }
      </mat-card-header>
      
      <mat-card-content>
        <ng-content></ng-content>
      </mat-card-content>
      
      @if (showActions()) {
        <mat-card-actions align="end">
          @if (canEdit()) {
            <button 
              mat-button 
              color="primary" 
              (click)="onEdit()"
              [disabled]="loading()"
            >
              <mat-icon>edit</mat-icon>
              Edit
            </button>
          }
          
          @if (canDelete()) {
            <button 
              mat-button 
              color="warn" 
              (click)="onDelete()"
              [disabled]="loading()"
            >
              <mat-icon>delete</mat-icon>
              Delete
            </button>
          }
          
          @for (action of customActions(); track action.id) {
            <button 
              mat-button 
              [color]="action.color || 'primary'"
              (click)="onCustomAction(action)"
              [disabled]="loading()"
            >
              @if (action.icon) {
                <mat-icon>{{ action.icon }}</mat-icon>
              }
              {{ action.label }}
            </button>
          }
        </mat-card-actions>
      }
    </mat-card>
  `,
  styleUrl: './generic-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class GenericCardComponent {
  // Use inject() instead of constructor injection for better performance
  // Services are only loaded when actually needed
  
  // Required inputs
  item = input.required<GenericItem>();
  
  // Optional inputs with defaults
  loading = input(false);
  canEdit = input(true);
  canDelete = input(true);
  customActions = input<CustomAction[]>([]);
  
  // Computed values
  showActions = computed(() => 
    this.canEdit() || this.canDelete() || this.customActions().length > 0
  );
  
  // Outputs
  editClicked = output<GenericItem>();
  deleteClicked = output<GenericItem>();
  customActionClicked = output<{ item: GenericItem; action: CustomAction }>();
  
  // Actions
  onEdit(): void {
    this.editClicked.emit(this.item());
  }
  
  onDelete(): void {
    this.deleteClicked.emit(this.item());
  }
  
  onCustomAction(action: CustomAction): void {
    this.customActionClicked.emit({ 
      item: this.item(), 
      action 
    });
  }
}

export interface CustomAction {
  id: string;
  label: string;
  icon?: string;
  color?: 'primary' | 'accent' | 'warn';
}