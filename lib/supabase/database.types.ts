export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      admin_permission_assignments: {
        Row: {
          created_at: string
          expires_at: string | null
          grant_source: Database["public"]["Enums"]["admin_grant_source"]
          granted_by_profile_id: string | null
          id: string
          permission_id: string
          profile_id: string
          provisioning_change_ref: string | null
          reason: string
          revoked_at: string | null
          scope_id: string | null
          scope_type: Database["public"]["Enums"]["admin_scope_type"]
          starts_at: string
        }
        Insert: {
          created_at?: string
          expires_at?: string | null
          grant_source: Database["public"]["Enums"]["admin_grant_source"]
          granted_by_profile_id?: string | null
          id?: string
          permission_id: string
          profile_id: string
          provisioning_change_ref?: string | null
          reason: string
          revoked_at?: string | null
          scope_id?: string | null
          scope_type: Database["public"]["Enums"]["admin_scope_type"]
          starts_at?: string
        }
        Update: {
          created_at?: string
          expires_at?: string | null
          grant_source?: Database["public"]["Enums"]["admin_grant_source"]
          granted_by_profile_id?: string | null
          id?: string
          permission_id?: string
          profile_id?: string
          provisioning_change_ref?: string | null
          reason?: string
          revoked_at?: string | null
          scope_id?: string | null
          scope_type?: Database["public"]["Enums"]["admin_scope_type"]
          starts_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "admin_permission_assignments_granted_by_profile_id_fkey"
            columns: ["granted_by_profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "admin_permission_assignments_permission_id_fkey"
            columns: ["permission_id"]
            isOneToOne: false
            referencedRelation: "admin_permissions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "admin_permission_assignments_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      admin_permissions: {
        Row: {
          active: boolean
          code: string
          created_at: string
          description: string
          id: string
          risk: Database["public"]["Enums"]["admin_risk"]
          updated_at: string
        }
        Insert: {
          active?: boolean
          code: string
          created_at?: string
          description: string
          id?: string
          risk: Database["public"]["Enums"]["admin_risk"]
          updated_at?: string
        }
        Update: {
          active?: boolean
          code?: string
          created_at?: string
          description?: string
          id?: string
          risk?: Database["public"]["Enums"]["admin_risk"]
          updated_at?: string
        }
        Relationships: []
      }
      app_environment: {
        Row: {
          demo_allowed: boolean
          environment: Database["public"]["Enums"]["deployment_environment"]
          mock_payment_allowed: boolean
          provisioned_at: string
          provisioning_change_ref: string
          singleton: boolean
        }
        Insert: {
          demo_allowed: boolean
          environment: Database["public"]["Enums"]["deployment_environment"]
          mock_payment_allowed: boolean
          provisioned_at: string
          provisioning_change_ref: string
          singleton?: boolean
        }
        Update: {
          demo_allowed?: boolean
          environment?: Database["public"]["Enums"]["deployment_environment"]
          mock_payment_allowed?: boolean
          provisioned_at?: string
          provisioning_change_ref?: string
          singleton?: boolean
        }
        Relationships: []
      }
      audit_events: {
        Row: {
          action: string
          actor_kind: Database["public"]["Enums"]["audit_actor_kind"]
          actor_profile_id: string | null
          causation_id: string | null
          correlation_id: string
          from_state: string | null
          id: string
          ip_hash: string | null
          object_id: string
          object_type: string
          occurred_at: string
          permission_code: string | null
          reason_code: string | null
          request_id: string
          safe_metadata: Json
          to_state: string | null
          user_agent_hash: string | null
        }
        Insert: {
          action: string
          actor_kind: Database["public"]["Enums"]["audit_actor_kind"]
          actor_profile_id?: string | null
          causation_id?: string | null
          correlation_id: string
          from_state?: string | null
          id?: string
          ip_hash?: string | null
          object_id: string
          object_type: string
          occurred_at?: string
          permission_code?: string | null
          reason_code?: string | null
          request_id: string
          safe_metadata?: Json
          to_state?: string | null
          user_agent_hash?: string | null
        }
        Update: {
          action?: string
          actor_kind?: Database["public"]["Enums"]["audit_actor_kind"]
          actor_profile_id?: string | null
          causation_id?: string | null
          correlation_id?: string
          from_state?: string | null
          id?: string
          ip_hash?: string | null
          object_id?: string
          object_type?: string
          occurred_at?: string
          permission_code?: string | null
          reason_code?: string | null
          request_id?: string
          safe_metadata?: Json
          to_state?: string | null
          user_agent_hash?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "audit_events_actor_profile_id_fkey"
            columns: ["actor_profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      contact_verifications: {
        Row: {
          channel: Database["public"]["Enums"]["contact_channel"]
          created_at: string
          destination_hash: string
          expires_at: string | null
          id: string
          profile_id: string
          state: Database["public"]["Enums"]["contact_verification_state"]
          updated_at: string
          verified_at: string | null
        }
        Insert: {
          channel: Database["public"]["Enums"]["contact_channel"]
          created_at?: string
          destination_hash: string
          expires_at?: string | null
          id?: string
          profile_id: string
          state?: Database["public"]["Enums"]["contact_verification_state"]
          updated_at?: string
          verified_at?: string | null
        }
        Update: {
          channel?: Database["public"]["Enums"]["contact_channel"]
          created_at?: string
          destination_hash?: string
          expires_at?: string | null
          id?: string
          profile_id?: string
          state?: Database["public"]["Enums"]["contact_verification_state"]
          updated_at?: string
          verified_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "contact_verifications_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      idempotency_records: {
        Row: {
          command_name: string
          completed_at: string | null
          correlation_id: string
          created_at: string
          expires_at: string
          id: string
          idempotency_key: string
          input_hash: string
          result_code: string | null
          result_object_id: string | null
          result_object_type: string | null
          scope: string
          state: Database["public"]["Enums"]["idempotency_state"]
        }
        Insert: {
          command_name: string
          completed_at?: string | null
          correlation_id: string
          created_at?: string
          expires_at: string
          id?: string
          idempotency_key: string
          input_hash: string
          result_code?: string | null
          result_object_id?: string | null
          result_object_type?: string | null
          scope: string
          state?: Database["public"]["Enums"]["idempotency_state"]
        }
        Update: {
          command_name?: string
          completed_at?: string | null
          correlation_id?: string
          created_at?: string
          expires_at?: string
          id?: string
          idempotency_key?: string
          input_hash?: string
          result_code?: string | null
          result_object_id?: string | null
          result_object_type?: string | null
          scope?: string
          state?: Database["public"]["Enums"]["idempotency_state"]
        }
        Relationships: []
      }
      outbox_event_deliveries: {
        Row: {
          attempt_count: number
          available_at: string
          claimed_at: string | null
          consumer_name: string
          event_id: string
          last_error_code: string | null
          processed_at: string | null
          state: Database["public"]["Enums"]["outbox_delivery_state"]
        }
        Insert: {
          attempt_count?: number
          available_at?: string
          claimed_at?: string | null
          consumer_name: string
          event_id: string
          last_error_code?: string | null
          processed_at?: string | null
          state?: Database["public"]["Enums"]["outbox_delivery_state"]
        }
        Update: {
          attempt_count?: number
          available_at?: string
          claimed_at?: string | null
          consumer_name?: string
          event_id?: string
          last_error_code?: string | null
          processed_at?: string | null
          state?: Database["public"]["Enums"]["outbox_delivery_state"]
        }
        Relationships: [
          {
            foreignKeyName: "outbox_event_deliveries_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "outbox_events"
            referencedColumns: ["id"]
          },
        ]
      }
      outbox_events: {
        Row: {
          aggregate_id: string
          aggregate_type: string
          aggregate_version: number
          causation_id: string | null
          correlation_id: string
          created_at: string
          event_name: string
          fanout_completed_at: string | null
          fully_processed_at: string | null
          id: string
          payload: Json
          payload_version: number
          terminal_failed_at: string | null
        }
        Insert: {
          aggregate_id: string
          aggregate_type: string
          aggregate_version: number
          causation_id?: string | null
          correlation_id: string
          created_at?: string
          event_name: string
          fanout_completed_at?: string | null
          fully_processed_at?: string | null
          id?: string
          payload: Json
          payload_version: number
          terminal_failed_at?: string | null
        }
        Update: {
          aggregate_id?: string
          aggregate_type?: string
          aggregate_version?: number
          causation_id?: string | null
          correlation_id?: string
          created_at?: string
          event_name?: string
          fanout_completed_at?: string | null
          fully_processed_at?: string | null
          id?: string
          payload?: Json
          payload_version?: number
          terminal_failed_at?: string | null
        }
        Relationships: []
      }
      profiles: {
        Row: {
          account_state: Database["public"]["Enums"]["account_state"]
          auth_user_id: string
          avatar_attachment_id: string | null
          created_at: string
          deactivated_at: string | null
          display_name: string
          id: string
          is_demo: boolean
          locale: string
          lock_version: number
          timezone: string
          updated_at: string
        }
        Insert: {
          account_state?: Database["public"]["Enums"]["account_state"]
          auth_user_id: string
          avatar_attachment_id?: string | null
          created_at?: string
          deactivated_at?: string | null
          display_name: string
          id?: string
          is_demo?: boolean
          locale?: string
          lock_version?: number
          timezone?: string
          updated_at?: string
        }
        Update: {
          account_state?: Database["public"]["Enums"]["account_state"]
          auth_user_id?: string
          avatar_attachment_id?: string | null
          created_at?: string
          deactivated_at?: string | null
          display_name?: string
          id?: string
          is_demo?: boolean
          locale?: string
          lock_version?: number
          timezone?: string
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      current_effective_admin_permissions: {
        Args: never
        Returns: {
          effective_expiry: string
          effective_start: string
          permission_code: string
          scope_id: string
          scope_type: Database["public"]["Enums"]["admin_scope_type"]
        }[]
      }
      current_profile_id: { Args: never; Returns: string }
      grant_admin_permission: {
        Args: {
          grant_reason: string
          permission_code: string
          recipient_profile_id: string
          requested_scope_id: string
          requested_scope_type: Database["public"]["Enums"]["admin_scope_type"]
        }
        Returns: string
      }
      has_admin_permission: {
        Args: {
          permission_code: string
          requested_scope_id?: string
          requested_scope_type?: Database["public"]["Enums"]["admin_scope_type"]
        }
        Returns: boolean
      }
      revoke_admin_permission: {
        Args: { assignment_id: string; revoke_reason: string }
        Returns: boolean
      }
      update_current_profile: {
        Args: {
          expected_lock_version: number
          new_display_name: string
          new_locale: string
          new_timezone: string
        }
        Returns: Database["public"]["CompositeTypes"]["profile_update_result"]
        SetofOptions: {
          from: "*"
          to: "profile_update_result"
          isOneToOne: true
          isSetofReturn: false
        }
      }
    }
    Enums: {
      account_state:
        | "active"
        | "limited"
        | "suspended"
        | "banned"
        | "appeal_pending"
        | "deactivated"
      admin_grant_source: "admin" | "provisioning"
      admin_risk: "ordinary" | "high"
      admin_scope_type: "global" | "locality"
      audit_actor_kind: "user" | "admin" | "system" | "system_provisioning"
      contact_channel: "email" | "phone"
      contact_verification_state: "pending" | "verified" | "expired" | "revoked"
      deployment_environment: "development" | "test" | "staging" | "production"
      idempotency_state: "processing" | "completed" | "failed"
      outbox_delivery_state:
        | "pending"
        | "claimed"
        | "retry"
        | "processed"
        | "dead_letter"
      profile_update_code:
        | "ok"
        | "forbidden"
        | "validation_failed"
        | "stale_version"
    }
    CompositeTypes: {
      admin_permission_scope_request: {
        permission_code: string | null
        scope_type: Database["public"]["Enums"]["admin_scope_type"] | null
        scope_id: string | null
      }
      profile_update_result: {
        success: boolean | null
        code: Database["public"]["Enums"]["profile_update_code"] | null
        lock_version: number | null
      }
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      account_state: [
        "active",
        "limited",
        "suspended",
        "banned",
        "appeal_pending",
        "deactivated",
      ],
      admin_grant_source: ["admin", "provisioning"],
      admin_risk: ["ordinary", "high"],
      admin_scope_type: ["global", "locality"],
      audit_actor_kind: ["user", "admin", "system", "system_provisioning"],
      contact_channel: ["email", "phone"],
      contact_verification_state: ["pending", "verified", "expired", "revoked"],
      deployment_environment: ["development", "test", "staging", "production"],
      idempotency_state: ["processing", "completed", "failed"],
      outbox_delivery_state: [
        "pending",
        "claimed",
        "retry",
        "processed",
        "dead_letter",
      ],
      profile_update_code: [
        "ok",
        "forbidden",
        "validation_failed",
        "stale_version",
      ],
    },
  },
} as const

